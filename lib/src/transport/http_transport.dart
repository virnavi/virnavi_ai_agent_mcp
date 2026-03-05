import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../core/dispatcher.dart';

/// Exposes registered tools and resources via an embedded HTTP server
/// using JSON-RPC 2.0 — compatible with MCP clients.
///
/// Works in debug, profile, and release modes (unlike VmServiceTransport).
///
/// Start with:
/// ```dart
/// final transport = HttpTransport(dispatcher, port: 8765);
/// await transport.start();
/// ```
///
/// JSON-RPC 2.0 endpoint: POST http://localhost:<port>/mcp
///
/// Supported methods:
///   tools/list           — list all registered tools
///   tools/call           — invoke a tool  { name, arguments }
///   resources/list       — list all registered resources
///   resources/read       — read a resource  { uri }
class HttpTransport {
  final Dispatcher _dispatcher;
  final int port;
  final String host;

  HttpServer? _server;

  HttpTransport(
    this._dispatcher, {
    this.port = 8765,
    this.host = '127.0.0.1',
  });

  /// Starts the HTTP server. Returns when the server is ready.
  Future<void> start() async {
    _server = await HttpServer.bind(host, port);
    _server!.listen(_handleRequest);
  }

  /// Stops the HTTP server.
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _handleRequest(HttpRequest request) async {
    // CORS — allow MCP clients running locally
    request.response.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Methods', 'POST, OPTIONS')
      ..set('Access-Control-Allow-Headers', 'Content-Type')
      ..contentType = ContentType.json;

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      return;
    }

    if (request.method != 'POST' || request.uri.path != '/mcp') {
      _sendError(request.response, null, -32600, 'Use POST /mcp');
      return;
    }

    final body = await utf8.decoder.bind(request).join();
    Map<String, dynamic> rpc;
    try {
      rpc = json.decode(body) as Map<String, dynamic>;
    } catch (_) {
      _sendError(request.response, null, -32700, 'Parse error');
      return;
    }

    final id = rpc['id'];
    final method = rpc['method'] as String?;
    final params = (rpc['params'] as Map<String, dynamic>?) ?? {};

    if (method == null) {
      _sendError(request.response, id, -32600, 'Missing method');
      return;
    }

    switch (method) {
      case 'tools/list':
        _sendResult(request.response, id, {'tools': _dispatcher.listTools()});

      case 'tools/call':
        final name = params['name'] as String?;
        if (name == null) {
          _sendError(request.response, id, -32602, 'Missing param: name');
          return;
        }
        final args = (params['arguments'] as Map<String, dynamic>?) ?? {};
        final result = await _dispatcher.callTool(name, args);
        _sendResult(request.response, id, result.toJson());

      case 'resources/list':
        _sendResult(
            request.response, id, {'resources': _dispatcher.listResources()});

      case 'resources/read':
        final uri = params['uri'] as String?;
        if (uri == null) {
          _sendError(request.response, id, -32602, 'Missing param: uri');
          return;
        }
        final content = await _dispatcher.readResource(uri);
        _sendResult(request.response, id, content.toJson());

      default:
        _sendError(request.response, id, -32601, 'Method not found: $method');
    }
  }

  void _sendResult(HttpResponse response, dynamic id, dynamic result) {
    response.statusCode = HttpStatus.ok;
    response.write(json.encode({
      'jsonrpc': '2.0',
      'id': id,
      'result': result,
    }));
    response.close();
  }

  void _sendError(
      HttpResponse response, dynamic id, int code, String message) {
    response.statusCode = HttpStatus.ok; // JSON-RPC errors use 200
    response.write(json.encode({
      'jsonrpc': '2.0',
      'id': id,
      'error': {'code': code, 'message': message},
    }));
    response.close();
  }
}

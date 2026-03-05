import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import '../core/dispatcher.dart';

/// Exposes the registered tools and resources to AI agents via
/// Dart VM service extensions. Works in debug mode.
///
/// MCP-style endpoints registered:
///   ext.virnavi.tools/list      — list all tools
///   ext.virnavi.tools/call      — invoke a tool
///   ext.virnavi.resources/list  — list all resources
///   ext.virnavi.resources/read  — read a resource
class VmServiceTransport {
  final Dispatcher _dispatcher;

  VmServiceTransport(this._dispatcher);

  void register() {
    registerExtension('ext.virnavi.tools/list', _listTools);
    registerExtension('ext.virnavi.tools/call', _callTool);
    registerExtension('ext.virnavi.resources/list', _listResources);
    registerExtension('ext.virnavi.resources/read', _readResource);
  }

  Future<ServiceExtensionResponse> _listTools(
    String method,
    Map<String, String> params,
  ) async {
    final tools = _dispatcher.listTools();
    return ServiceExtensionResponse.result(json.encode({'tools': tools}));
  }

  Future<ServiceExtensionResponse> _callTool(
    String method,
    Map<String, String> params,
  ) async {
    final name = params['name'];
    if (name == null) {
      return ServiceExtensionResponse.error(
        ServiceExtensionResponse.extensionErrorMin,
        'Missing required param: "name"',
      );
    }

    Map<String, dynamic> args = {};
    final rawArgs = params['args'];
    if (rawArgs != null) {
      try {
        args = json.decode(rawArgs) as Map<String, dynamic>;
      } catch (_) {
        return ServiceExtensionResponse.error(
          ServiceExtensionResponse.extensionErrorMin,
          'Invalid JSON in "args"',
        );
      }
    }

    final result = await _dispatcher.callTool(name, args);
    return ServiceExtensionResponse.result(json.encode(result.toJson()));
  }

  Future<ServiceExtensionResponse> _listResources(
    String method,
    Map<String, String> params,
  ) async {
    final resources = _dispatcher.listResources();
    return ServiceExtensionResponse.result(json.encode({'resources': resources}));
  }

  Future<ServiceExtensionResponse> _readResource(
    String method,
    Map<String, String> params,
  ) async {
    final uri = params['uri'];
    if (uri == null) {
      return ServiceExtensionResponse.error(
        ServiceExtensionResponse.extensionErrorMin,
        'Missing required param: "uri"',
      );
    }
    final content = await _dispatcher.readResource(uri);
    return ServiceExtensionResponse.result(json.encode(content.toJson()));
  }
}

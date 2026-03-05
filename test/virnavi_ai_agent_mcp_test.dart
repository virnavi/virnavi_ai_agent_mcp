import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

void main() {
  group('ToolRegistry + Dispatcher', () {
    late ToolRegistry registry;
    late Dispatcher dispatcher;

    setUp(() {
      registry = ToolRegistry();
      dispatcher = Dispatcher(registry);
    });

    test('registers and lists tools', () {
      registry.registerTool(ToolDefinition(
        name: 'say_hello',
        description: 'Returns a greeting',
        inputSchema: ObjectSchema(
          properties: {'name': StringSchema(description: 'Person name')},
          required: ['name'],
        ),
        handler: (args) async =>
            ToolResult.success('Hello, ${args['name']}!'),
      ));

      final tools = dispatcher.listTools();
      expect(tools.length, 1);
      expect(tools.first['name'], 'say_hello');
    });

    test('calls a tool and returns success result', () async {
      registry.registerTool(ToolDefinition(
        name: 'add',
        description: 'Adds two numbers',
        inputSchema: ObjectSchema(
          properties: {
            'a': NumberSchema(),
            'b': NumberSchema(),
          },
          required: ['a', 'b'],
        ),
        handler: (args) async {
          final result = (args['a'] as num) + (args['b'] as num);
          return ToolResult.success(result);
        },
      ));

      final result = await dispatcher.callTool('add', {'a': 3, 'b': 4});
      expect(result.isError, false);
      expect(result.data, 7);
    });

    test('returns error for unknown tool', () async {
      final result = await dispatcher.callTool('unknown', {});
      expect(result.isError, true);
      expect(result.errorMessage, contains('Unknown tool'));
    });

    test('registers and reads a resource', () async {
      registry.registerResource(ResourceDefinition(
        name: 'app_version',
        description: 'Current app version',
        uri: 'virnavi://app/version',
        reader: () async => ResourceContent(data: {'version': '1.0.0'}),
      ));

      final content = await dispatcher.readResource('virnavi://app/version');
      expect(content.data['version'], '1.0.0');
    });

    test('schema serializes correctly', () {
      final schema = ObjectSchema(
        properties: {
          'id': StringSchema(description: 'User ID'),
          'age': IntegerSchema(minimum: 0, maximum: 150),
        },
        required: ['id'],
      );

      final json = schema.toJson();
      expect(json['type'], 'object');
      expect(json['properties']['id']['type'], 'string');
      expect(json['properties']['age']['minimum'], 0);
      expect(json['required'], ['id']);
    });
  });

  group('HttpTransport', () {
    late ToolRegistry registry;
    late Dispatcher dispatcher;
    late HttpTransport transport;

    setUp(() async {
      registry = ToolRegistry();
      dispatcher = Dispatcher(registry);
      registry.registerTool(ToolDefinition(
        name: 'multiply',
        description: 'Multiplies two numbers',
        inputSchema: ObjectSchema(
          properties: {
            'a': NumberSchema(),
            'b': NumberSchema(),
          },
          required: ['a', 'b'],
        ),
        handler: (args) async {
          final result = (args['a'] as num) * (args['b'] as num);
          return ToolResult.success(result);
        },
      ));
      transport = HttpTransport(dispatcher, port: 18765);
      await transport.start();
    });

    tearDown(() async {
      await transport.stop();
    });

    Future<Map<String, dynamic>> rpc(Map<String, dynamic> body) async {
      final client = HttpClient();
      final request = await client.postUrl(
          Uri.parse('http://localhost:18765/mcp'));
      request.headers.contentType = ContentType.json;
      request.write(json.encode(body));
      final response = await request.close();
      final raw = await utf8.decoder.bind(response).join();
      client.close();
      return json.decode(raw) as Map<String, dynamic>;
    }

    test('tools/list returns registered tools', () async {
      final res = await rpc({'jsonrpc': '2.0', 'id': 1, 'method': 'tools/list', 'params': {}});
      expect(res['result']['tools'].length, 1);
      expect(res['result']['tools'][0]['name'], 'multiply');
    });

    test('tools/call invokes the handler', () async {
      final res = await rpc({
        'jsonrpc': '2.0',
        'id': 2,
        'method': 'tools/call',
        'params': {'name': 'multiply', 'arguments': {'a': 6, 'b': 7}},
      });
      expect(res['result']['isError'], false);
      expect(res['result']['data'], 42);
    });

    test('tools/call unknown tool returns error result', () async {
      final res = await rpc({
        'jsonrpc': '2.0',
        'id': 3,
        'method': 'tools/call',
        'params': {'name': 'nope', 'arguments': {}},
      });
      expect(res['result']['isError'], true);
    });

    test('unknown method returns JSON-RPC error', () async {
      final res = await rpc({
        'jsonrpc': '2.0',
        'id': 4,
        'method': 'bad/method',
        'params': {},
      });
      expect(res['error']['code'], -32601);
    });
  });
}

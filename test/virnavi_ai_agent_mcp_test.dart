import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

void main() {
  // ── Schema ─────────────────────────────────────────────────────────────────

  group('StringSchema', () {
    test('minimal toJson', () {
      final j = StringSchema().toJson();
      expect(j['type'], 'string');
      expect(j.containsKey('description'), false);
      expect(j.containsKey('enum'), false);
    });

    test('with description and enum', () {
      final j = StringSchema(
        description: 'Color choice',
        enumValues: ['red', 'green', 'blue'],
      ).toJson();
      expect(j['description'], 'Color choice');
      expect(j['enum'], ['red', 'green', 'blue']);
    });
  });

  group('IntegerSchema', () {
    test('minimal toJson', () {
      expect(IntegerSchema().toJson()['type'], 'integer');
    });

    test('with min and max', () {
      final j = IntegerSchema(description: 'Age', minimum: 0, maximum: 120).toJson();
      expect(j['description'], 'Age');
      expect(j['minimum'], 0);
      expect(j['maximum'], 120);
    });
  });

  group('NumberSchema', () {
    test('toJson includes type number', () {
      expect(NumberSchema().toJson()['type'], 'number');
    });

    test('with bounds', () {
      final j = NumberSchema(minimum: -1.5, maximum: 1.5).toJson();
      expect(j['minimum'], -1.5);
      expect(j['maximum'], 1.5);
    });
  });

  group('BooleanSchema', () {
    test('toJson', () {
      final j = BooleanSchema(description: 'Flag').toJson();
      expect(j['type'], 'boolean');
      expect(j['description'], 'Flag');
    });
  });

  group('ArraySchema', () {
    test('toJson nests items', () {
      final j = ArraySchema(items: StringSchema(description: 'Tag')).toJson();
      expect(j['type'], 'array');
      expect(j['items']['type'], 'string');
      expect(j['items']['description'], 'Tag');
    });
  });

  group('ObjectSchema', () {
    test('empty schema', () {
      final j = ObjectSchema().toJson();
      expect(j['type'], 'object');
      expect(j.containsKey('properties'), false);
      expect(j.containsKey('required'), false);
    });

    test('with properties and required', () {
      final j = ObjectSchema(
        properties: {
          'id': StringSchema(description: 'User ID'),
          'age': IntegerSchema(minimum: 0, maximum: 150),
        },
        required: ['id'],
      ).toJson();
      expect(j['properties']['id']['type'], 'string');
      expect(j['properties']['age']['minimum'], 0);
      expect(j['required'], ['id']);
    });
  });

  // ── ToolResult ─────────────────────────────────────────────────────────────

  group('ToolResult', () {
    test('success toJson', () {
      final j = ToolResult.success({'key': 'value'}).toJson();
      expect(j['isError'], false);
      expect(j['data'], {'key': 'value'});
      expect(j.containsKey('error'), false);
    });

    test('error toJson', () {
      final j = ToolResult.error('something went wrong').toJson();
      expect(j['isError'], true);
      expect(j['error'], 'something went wrong');
      expect(j.containsKey('data'), false);
    });

    test('success with null data', () {
      final result = ToolResult.success(null);
      expect(result.isError, false);
      expect(result.data, isNull);
    });
  });

  // ── ResourceContent ────────────────────────────────────────────────────────

  group('ResourceContent', () {
    test('default mimeType is application/json', () {
      final c = ResourceContent(data: {'v': 1});
      expect(c.mimeType, 'application/json');
    });

    test('toJson', () {
      final j = ResourceContent(data: [1, 2, 3], mimeType: 'text/plain').toJson();
      expect(j['mimeType'], 'text/plain');
      expect(j['data'], [1, 2, 3]);
    });
  });

  // ── ToolRegistry ───────────────────────────────────────────────────────────

  group('ToolRegistry', () {
    late ToolRegistry registry;

    setUp(() => registry = ToolRegistry());

    test('registers and retrieves a tool', () {
      final tool = _echoTool();
      registry.registerTool(tool);
      expect(registry.getTool('echo'), same(tool));
    });

    test('tools list is unmodifiable', () {
      registry.registerTool(_echoTool());
      expect(registry.tools.length, 1);
      expect(() => (registry.tools as dynamic).add(null), throwsUnsupportedError);
    });

    test('returns null for unregistered tool', () {
      expect(registry.getTool('nope'), isNull);
    });

    test('registers and retrieves a resource', () {
      final resource = _versionResource();
      registry.registerResource(resource);
      expect(registry.getResource('virnavi://version'), same(resource));
    });
  });

  // ── Dispatcher ─────────────────────────────────────────────────────────────

  group('Dispatcher', () {
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
        handler: (args) async => ToolResult.success('Hello, ${args['name']}!'),
      ));

      final tools = dispatcher.listTools();
      expect(tools.length, 1);
      expect(tools.first['name'], 'say_hello');
    });

    test('calls a tool successfully', () async {
      registry.registerTool(ToolDefinition(
        name: 'add',
        description: 'Adds two numbers',
        inputSchema: ObjectSchema(
          properties: {'a': NumberSchema(), 'b': NumberSchema()},
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

    test('catches exceptions thrown by handler', () async {
      registry.registerTool(ToolDefinition(
        name: 'boom',
        description: 'Always throws',
        inputSchema: ObjectSchema(),
        handler: (_) async => throw Exception('crash!'),
      ));

      final result = await dispatcher.callTool('boom', {});
      expect(result.isError, true);
      expect(result.errorMessage, contains('crash!'));
    });

    test('listResources returns registered resources', () {
      registry.registerResource(_versionResource());
      final resources = dispatcher.listResources();
      expect(resources.length, 1);
      expect(resources.first['uri'], 'virnavi://version');
    });

    test('reads a registered resource', () async {
      registry.registerResource(_versionResource());
      final content = await dispatcher.readResource('virnavi://version');
      expect(content.data['version'], '1.0.0');
    });

    test('reading unknown resource returns error data', () async {
      final content = await dispatcher.readResource('virnavi://nope');
      expect((content.data as Map).containsKey('error'), true);
    });
  });

  // ── HttpTransport ──────────────────────────────────────────────────────────

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
          properties: {'a': NumberSchema(), 'b': NumberSchema()},
          required: ['a', 'b'],
        ),
        handler: (args) async {
          final result = (args['a'] as num) * (args['b'] as num);
          return ToolResult.success(result);
        },
      ));
      registry.registerResource(_versionResource());
      transport = HttpTransport(dispatcher, port: 18765);
      await transport.start();
    });

    tearDown(() async => transport.stop());

    test('tools/list returns registered tools', () async {
      final res = await _rpc({'jsonrpc': '2.0', 'id': 1, 'method': 'tools/list', 'params': {}});
      expect(res['result']['tools'].length, 1);
      expect(res['result']['tools'][0]['name'], 'multiply');
    });

    test('tools/call invokes the handler', () async {
      final res = await _rpc({
        'jsonrpc': '2.0',
        'id': 2,
        'method': 'tools/call',
        'params': {'name': 'multiply', 'arguments': {'a': 6, 'b': 7}},
      });
      expect(res['result']['isError'], false);
      expect(res['result']['data'], 42);
    });

    test('tools/call unknown tool returns isError true', () async {
      final res = await _rpc({
        'jsonrpc': '2.0',
        'id': 3,
        'method': 'tools/call',
        'params': {'name': 'nope', 'arguments': {}},
      });
      expect(res['result']['isError'], true);
    });

    test('tools/call missing name param returns JSON-RPC error', () async {
      final res = await _rpc({
        'jsonrpc': '2.0',
        'id': 4,
        'method': 'tools/call',
        'params': {},
      });
      expect(res['error']['code'], -32602);
    });

    test('resources/list returns registered resources', () async {
      final res = await _rpc({'jsonrpc': '2.0', 'id': 5, 'method': 'resources/list', 'params': {}});
      expect(res['result']['resources'].length, 1);
      expect(res['result']['resources'][0]['uri'], 'virnavi://version');
    });

    test('resources/read returns resource content', () async {
      final res = await _rpc({
        'jsonrpc': '2.0',
        'id': 6,
        'method': 'resources/read',
        'params': {'uri': 'virnavi://version'},
      });
      expect(res['result']['data']['version'], '1.0.0');
    });

    test('resources/read missing uri returns JSON-RPC error', () async {
      final res = await _rpc({
        'jsonrpc': '2.0',
        'id': 7,
        'method': 'resources/read',
        'params': {},
      });
      expect(res['error']['code'], -32602);
    });

    test('unknown method returns JSON-RPC error -32601', () async {
      final res = await _rpc({'jsonrpc': '2.0', 'id': 8, 'method': 'bad/method', 'params': {}});
      expect(res['error']['code'], -32601);
    });

    test('invalid JSON body returns parse error -32700', () async {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('http://127.0.0.1:18765/mcp'));
      request.headers.contentType = ContentType.json;
      request.write('not json {{{');
      final response = await request.close();
      final raw = await utf8.decoder.bind(response).join();
      client.close();
      final res = json.decode(raw) as Map<String, dynamic>;
      expect(res['error']['code'], -32700);
    });

    test('CORS headers are present', () async {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('http://127.0.0.1:18765/mcp'));
      request.headers.contentType = ContentType.json;
      request.write(json.encode({'jsonrpc': '2.0', 'id': 9, 'method': 'tools/list', 'params': {}}));
      final response = await request.close();
      await response.drain<void>();
      client.close();
      expect(response.headers.value('access-control-allow-origin'), '*');
    });
  });
}

// ── Helpers ──────────────────────────────────────────────────────────────────

ToolDefinition _echoTool() => ToolDefinition(
      name: 'echo',
      description: 'Echoes input',
      inputSchema: ObjectSchema(),
      handler: (args) async => ToolResult.success(args),
    );

ResourceDefinition _versionResource() => ResourceDefinition(
      name: 'version',
      description: 'App version',
      uri: 'virnavi://version',
      reader: () async => ResourceContent(data: {'version': '1.0.0'}),
    );

Future<Map<String, dynamic>> _rpc(Map<String, dynamic> body) async {
  final client = HttpClient();
  final request = await client.postUrl(Uri.parse('http://127.0.0.1:18765/mcp'));
  request.headers.contentType = ContentType.json;
  request.write(json.encode(body));
  final response = await request.close();
  final raw = await utf8.decoder.bind(response).join();
  client.close();
  return json.decode(raw) as Map<String, dynamic>;
}

# virnavi_ai_agent_mcp

Expose Flutter app methods to AI agents via the [Model Context Protocol (MCP)](https://modelcontextprotocol.io).

Register your Flutter app's methods as MCP tools — AI agents can then discover and invoke them over JSON-RPC 2.0, in debug, profile, and release modes.

## Features

- **Embedded HTTP server** — `POST /mcp` endpoint, works in all build modes.
- **VM service transport** — zero-config debug-mode transport via Dart VM extensions.
- **Tool & resource registry** — register any Flutter method as an MCP tool or resource.
- **Typed JSON Schema** — `StringSchema`, `IntegerSchema`, `NumberSchema`, `BooleanSchema`, `ArraySchema`, `ObjectSchema`.
- **Annotation support** — use `@McpService` / `@McpTool` / `@McpModel` with the companion generator package ([virnavi_ai_agent_mcp_generator](https://github.com/virnavi/virnavi_ai_agent_mcp/tree/main/generator)) to auto-generate tool definitions at build time.
- **Reactive UI** — pair with [virnavi_ai_agent_compose](https://github.com/virnavi/virnavi_ai_agent_mcp/tree/main/compose) to rebuild Flutter widgets reactively when agents invoke tools.

## Getting started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  virnavi_ai_agent_mcp: ^0.0.1
```

## Usage

### Manual registration

```dart
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AgentBridge.instance
      .initialize()                           // VM service (debug only)
      .startHttpServer(port: 8765);           // HTTP (all modes)

  AgentBridge.instance.registerTool(ToolDefinition(
    name: 'packages/my_app/mcp/tasks/list',
    description: 'Returns all tasks.',
    inputSchema: ObjectSchema(),
    handler: (args) async {
      final tasks = await taskRepo.getAll();
      return ToolResult.success(tasks.map((t) => t.toJson()).toList());
    },
  ));

  runApp(const MyApp());
}
```

### Annotation-driven (with generator)

Annotate your service class and run `build_runner` — tool definitions are generated automatically:

```dart
// task_service.dart
part 'task_service.mcp.dart';

@McpService(path: 'tasks')
class TaskService {
  @McpTool(path: 'list', description: 'Returns all tasks.')
  Future<List<Task>> listTasks() async => repo.getAll();

  @McpTool(path: 'create', description: 'Creates a new task.')
  Future<Task> createTask(CreateTaskInput input) async => repo.add(input);
}
```

```dart
// main.dart
final service = TaskService(repo);
for (final tool in service.mcpTools) {
  AgentBridge.instance.registerTool(tool);
}
```

```bash
dart run build_runner build
```

### Calling from an AI agent

```bash
curl -X POST http://127.0.0.1:8765/mcp \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}'
```

```bash
curl -X POST http://127.0.0.1:8765/mcp \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"packages/my_app/mcp/tasks/list","arguments":{}}}'
```

## Supported MCP methods

| Method | Description |
|---|---|
| `tools/list` | List all registered tools |
| `tools/call` | Invoke a tool by name |
| `resources/list` | List all registered resources |
| `resources/read` | Read a resource by URI |

## Related packages

| Package | Description |
|---|---|
| [virnavi_ai_agent_mcp_generator](https://github.com/virnavi/virnavi_ai_agent_mcp/tree/main/generator) | Build-time code generator for `@McpModel` / `@McpService` annotations |
| [virnavi_ai_agent_compose](https://github.com/virnavi/virnavi_ai_agent_mcp/tree/main/compose) | Reactive Flutter widgets that rebuild when agents invoke tools |

## License

MIT — see [LICENSE](LICENSE).

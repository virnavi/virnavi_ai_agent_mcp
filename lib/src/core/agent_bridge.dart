import '../definition/resource_definition.dart';
import '../definition/tool_definition.dart';
import '../transport/http_transport.dart';
import '../transport/vm_service_transport.dart';
import 'dispatcher.dart';
import 'tool_registry.dart';

/// The main entry point for virnavi_ai_agent_mcp.
///
/// Initialize in your Flutter app's main() and register your app's
/// methods as tools so AI agents can invoke them via the MCP protocol.
///
/// Two transports are available:
///   - VM service extensions (debug mode only, zero config)
///   - HTTP server (all modes, configurable port)
///
/// Example:
/// ```dart
/// await AgentBridge.instance
///   ..initialize()                          // VM service (debug)
///   ..await startHttpServer(port: 8765)     // HTTP (any mode)
///   ..registerTool(ToolDefinition(
///       name: 'get_user',
///       description: 'Fetch a user by ID',
///       inputSchema: ObjectSchema(
///         properties: {'id': StringSchema(description: 'User ID')},
///         required: ['id'],
///       ),
///       handler: (args) async {
///         final user = await userRepo.getById(args['id'] as String);
///         return ToolResult.success(user.toJson());
///       },
///   ));
/// ```
class AgentBridge {
  AgentBridge._();

  static final AgentBridge instance = AgentBridge._();

  final ToolRegistry _registry = ToolRegistry();
  late final Dispatcher _dispatcher = Dispatcher(_registry);
  late final VmServiceTransport _vmTransport = VmServiceTransport(_dispatcher);

  HttpTransport? _httpTransport;
  bool _initialized = false;

  /// Registers VM service extensions (debug mode only).
  /// Safe to call in release mode — asserts are stripped.
  AgentBridge initialize() {
    assert(!_initialized, 'AgentBridge.initialize() called more than once.');
    assert(() {
      _vmTransport.register();
      return true;
    }());
    _initialized = true;
    return this;
  }

  /// Starts an embedded HTTP server so AI agents can connect via JSON-RPC 2.0.
  ///
  /// Works in debug, profile, and release modes.
  /// POST http://localhost:[port]/mcp
  Future<AgentBridge> startHttpServer({
    int port = 8765,
    String host = '127.0.0.1',
  }) async {
    _httpTransport = HttpTransport(_dispatcher, port: port, host: host);
    await _httpTransport!.start();
    return this;
  }

  /// Stops the HTTP server if running.
  Future<void> stopHttpServer() async {
    await _httpTransport?.stop();
    _httpTransport = null;
  }

  /// Registers an app method as an MCP tool.
  AgentBridge registerTool(ToolDefinition tool) {
    _registry.registerTool(tool);
    return this;
  }

  /// Registers an app data source as an MCP resource.
  AgentBridge registerResource(ResourceDefinition resource) {
    _registry.registerResource(resource);
    return this;
  }
}

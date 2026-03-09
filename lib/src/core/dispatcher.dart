import '../result/resource_content.dart';
import '../result/tool_result.dart';
import 'tool_registry.dart';

/// Routes incoming AI agent requests to the correct registered handler.
class Dispatcher {
  final ToolRegistry _registry;

  Dispatcher(this._registry);

  /// Returns a JSON-serializable list of all registered tools.
  List<Map<String, dynamic>> listTools() =>
      _registry.tools.map((t) => t.toJson()).toList();

  /// Returns a JSON-serializable list of all registered resources.
  List<Map<String, dynamic>> listResources() =>
      _registry.resources.map((r) => r.toJson()).toList();

  /// Calls a registered tool by name with the provided arguments.
  Future<ToolResult> callTool(String name, Map<String, dynamic> args) async {
    final tool = _registry.getTool(name);
    if (tool == null) {
      return ToolResult.error('Unknown tool: "$name"');
    }
    try {
      return await tool.handler(args);
    } catch (e, stack) {
      return ToolResult.error('Tool "$name" threw an exception: $e\n$stack');
    }
  }

  /// Reads a registered resource by URI.
  Future<ResourceContent> readResource(String uri) async {
    final resource = _registry.getResource(uri);
    if (resource == null) {
      return ResourceContent(
        data: {'error': 'Unknown resource: "$uri"'},
      );
    }
    try {
      return await resource.reader();
    } catch (e, stack) {
      return ResourceContent(
        data: {'error': 'Resource "$uri" threw an exception: $e\n$stack'},
      );
    }
  }
}

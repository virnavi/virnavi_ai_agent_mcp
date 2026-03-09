import '../definition/resource_definition.dart';
import '../definition/tool_definition.dart';

/// Stores all registered tools and resources.
class ToolRegistry {
  final _tools = <String, ToolDefinition>{};
  final _resources = <String, ResourceDefinition>{};

  /// Registers a tool. Asserts (debug only) that the name is unique.
  void registerTool(ToolDefinition tool) {
    assert(!_tools.containsKey(tool.name),
        'Tool "${tool.name}" is already registered.');
    _tools[tool.name] = tool;
  }

  /// Registers a resource. Asserts (debug only) that the URI is unique.
  void registerResource(ResourceDefinition resource) {
    assert(!_resources.containsKey(resource.uri),
        'Resource "${resource.uri}" is already registered.');
    _resources[resource.uri] = resource;
  }

  /// Returns the [ToolDefinition] with the given [name], or null if not found.
  ToolDefinition? getTool(String name) => _tools[name];

  /// Returns the [ResourceDefinition] with the given [uri], or null if not found.
  ResourceDefinition? getResource(String uri) => _resources[uri];

  /// All registered tools, in insertion order.
  List<ToolDefinition> get tools => List.unmodifiable(_tools.values);

  /// All registered resources, in insertion order.
  List<ResourceDefinition> get resources => List.unmodifiable(_resources.values);
}

import '../definition/resource_definition.dart';
import '../definition/tool_definition.dart';

/// Stores all registered tools and resources.
class ToolRegistry {
  final _tools = <String, ToolDefinition>{};
  final _resources = <String, ResourceDefinition>{};

  void registerTool(ToolDefinition tool) {
    assert(!_tools.containsKey(tool.name),
        'Tool "${tool.name}" is already registered.');
    _tools[tool.name] = tool;
  }

  void registerResource(ResourceDefinition resource) {
    assert(!_resources.containsKey(resource.uri),
        'Resource "${resource.uri}" is already registered.');
    _resources[resource.uri] = resource;
  }

  ToolDefinition? getTool(String name) => _tools[name];

  ResourceDefinition? getResource(String uri) => _resources[uri];

  List<ToolDefinition> get tools => List.unmodifiable(_tools.values);

  List<ResourceDefinition> get resources => List.unmodifiable(_resources.values);
}

import 'definition/tool_definition.dart';
import 'mcp_model_definition.dart';

/// A catalog of all MCP artifacts (tools, models, views) in a package/module.
///
/// **Dual-purpose class:**
/// - **Annotation**: `@McpSummary()` on a class → the generator scans the
///   whole package and creates a const static with all tool names, model
///   IDs and view model IDs pre-populated.
/// - **Runtime value**: call [bind] with your service's tool list and model
///   definitions to get a fully populated registry.
///
/// ### Typical usage
///
/// ```dart
/// // Generated convenience method in app_summary.mcp.dart:
/// _summary = $AppSummaryMcpSummary.bindWithViews(_service.mcpTools);
///
/// // Register tools:
/// _summary.tools.values.toList().registerWith(bridge, binding);
///
/// // Deserialize a model result without a switch statement:
/// final model = _summary.deserializeModel(modelId, json);
///
/// // Render the matching view widget (compose extension):
/// _summary.buildView(modelId, model);
///
/// // Merge two package summaries (no duplicates):
/// final combined = summaryA.merge(summaryB).bind([...toolsA, ...toolsB]);
/// ```
class McpSummary {
  /// Identifier for this summary (usually the package name).
  final String id;

  /// Full MCP tool names present in this package.
  /// Format: `packages/{package}/mcp/{servicePath}/{toolPath}`
  final Set<String> toolNames;

  /// Model IDs for all @McpModel classes.
  /// Format: `{package}/{name ?? ClassName}`
  final Set<String> modelIds;

  /// Model IDs for @McpModel classes that have a corresponding @McpView widget.
  final Set<String> viewModelIds;

  // null only for the generated const instance (annotation use).
  final Map<String, ToolDefinition>? _tools;
  final Map<String, McpModelDefinition>? _models;

  const McpSummary({
    this.id = '',
    this.toolNames = const {},
    this.modelIds = const {},
    this.viewModelIds = const {},
  })  : _tools = null,
        _models = null;

  McpSummary._bound({
    required this.id,
    required this.toolNames,
    required this.modelIds,
    required this.viewModelIds,
    required Map<String, ToolDefinition> tools,
    required Map<String, McpModelDefinition> models,
  })  : _tools = tools,
        _models = models;

  /// Bound tool definitions, keyed by full MCP tool name.
  /// Empty map until [bind] is called.
  Map<String, ToolDefinition> get tools => _tools ?? const {};

  /// Bound model definitions, keyed by model ID.
  /// Empty map until [bind] is called with a non-empty [models] list.
  Map<String, McpModelDefinition> get models => _models ?? const {};

  /// Binds [toolList] and optional [models] to this summary.
  ///
  /// Returns a new [McpSummary] with [tools] and [models] populated. Only
  /// tools whose [ToolDefinition.name] is in [toolNames] are kept, and the
  /// first occurrence of each name wins (deduplication).
  McpSummary bind(
    List<ToolDefinition> toolList, {
    List<McpModelDefinition> models = const [],
  }) {
    final seen = <String>{};
    final toolMap = <String, ToolDefinition>{};
    for (final t in toolList) {
      if (toolNames.contains(t.name) && seen.add(t.name)) {
        toolMap[t.name] = t;
      }
    }
    // Flatten nested definitions recursively (depth-first, first-occurrence wins).
    final modelMap = <String, McpModelDefinition>{};
    void register(McpModelDefinition def) {
      if (modelMap.containsKey(def.id)) return;
      modelMap[def.id] = def;
      for (final nested in def.nestedDefinitions) {
        register(nested);
      }
    }
    for (final m in models) {
      register(m);
    }
    return McpSummary._bound(
      id: id,
      toolNames: toolNames,
      modelIds: modelIds,
      viewModelIds: viewModelIds,
      tools: toolMap,
      models: modelMap,
    );
  }

  /// Deserializes [json] into the model registered under [modelId].
  /// Returns null if no model definition is registered for [modelId].
  Object? deserializeModel(String modelId, Map<String, dynamic> json) =>
      models[modelId]?.fromJson(json);

  /// Binds [views] to this summary. Views are resolved at runtime by the
  /// compose layer via model ID; by default this returns the summary unchanged.
  /// Override or extend in the compose package if view storage is needed.
  McpSummary bindViews(List<dynamic> views) => this;

  /// Returns a new [McpSummary] whose sets are the union of this and [other].
  /// If [id] is empty, [other]'s id is used.
  /// Duplicate tool names / model IDs are silently dropped (Set semantics).
  McpSummary merge(McpSummary other) => McpSummary(
        id: id.isEmpty ? other.id : id,
        toolNames: {...toolNames, ...other.toolNames},
        modelIds: {...modelIds, ...other.modelIds},
        viewModelIds: {...viewModelIds, ...other.viewModelIds},
      );
}

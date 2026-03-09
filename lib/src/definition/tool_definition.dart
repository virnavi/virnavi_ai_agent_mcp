import '../result/tool_result.dart';
import 'schema.dart';

typedef ToolHandler = Future<ToolResult> Function(Map<String, dynamic> args);

/// Defines a tool (a Flutter app method) that an AI agent can invoke.
class ToolDefinition {
  final String name;
  final String description;
  final ObjectSchema inputSchema;
  final ToolHandler handler;

  /// When this tool returns an @McpModel, this is the model's unique ID:
  /// `{package}/{name ?? ClassName}`.
  ///
  /// [McpComposeBinding] uses this as the [McpResultStore] key so that
  /// @McpView-generated widgets can listen by model ID rather than tool name.
  /// Null for tools that don't return a typed @McpModel.
  final String? resultModelId;

  const ToolDefinition({
    required this.name,
    required this.description,
    required this.inputSchema,
    required this.handler,
    this.resultModelId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'inputSchema': inputSchema.toJson(),
      };
}

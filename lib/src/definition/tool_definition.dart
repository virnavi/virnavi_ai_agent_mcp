import '../result/tool_result.dart';
import 'schema.dart';

typedef ToolHandler = Future<ToolResult> Function(Map<String, dynamic> args);

/// Defines a tool (a Flutter app method) that an AI agent can invoke.
class ToolDefinition {
  final String name;
  final String description;
  final ObjectSchema inputSchema;
  final ToolHandler handler;

  const ToolDefinition({
    required this.name,
    required this.description,
    required this.inputSchema,
    required this.handler,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'inputSchema': inputSchema.toJson(),
      };
}

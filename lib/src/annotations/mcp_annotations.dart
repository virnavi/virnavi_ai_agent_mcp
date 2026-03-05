/// Marks a Dart class as an MCP model.
///
/// Works alongside @JsonSerializable. The generator produces an
/// ObjectSchema for this class, respecting @JsonKey(name:) overrides
/// and @McpField metadata on each field.
///
/// Example:
/// ```dart
/// @McpModel()
/// @JsonSerializable()
/// class CreateTaskInput {
///   @McpField(description: 'Task title')
///   final String title;
///
///   @McpField(description: 'Optional details')
///   final String? description;
///
///   const CreateTaskInput({required this.title, this.description});
///   factory CreateTaskInput.fromJson(Map<String, dynamic> json) =>
///       _$CreateTaskInputFromJson(json);
///   Map<String, dynamic> toJson() => _$CreateTaskInputToJson(this);
/// }
/// ```
class McpModel {
  const McpModel();
}

/// Metadata for a field inside an @McpModel class.
///
/// Controls how the field appears in the generated ObjectSchema.
/// [required] defaults to inferring from the field's nullability
/// (non-nullable → required, nullable → optional).
class McpField {
  final String? description;

  /// Override the required status. When null, inferred from nullability.
  final bool? required;

  const McpField({this.description, this.required});
}

/// Marks a class as an MCP service, similar to Spring Boot's @RestController.
///
/// [path] is the base path segment for this service. All tools inside it will
/// be addressable as:
///   `packages/{package}/mcp/{path}/{toolPath}`
///
/// Example:
/// ```dart
/// @McpService(path: 'tasks')
/// class TaskService {
///   @McpTool(description: 'List all tasks')
///   Future<List<Map<String, dynamic>>> list() async { ... }
///   // tool name → packages/my_app/mcp/tasks/list
/// }
/// ```
class McpService {
  final String path;

  const McpService({required this.path});
}

/// Marks a method in an @McpService class as an MCP tool.
///
/// [path] is the tool's path segment appended after the service path.
/// Defaults to the method name converted to snake_case if omitted.
///
/// Full tool name: `packages/{package}/mcp/{servicePath}/{path}`
///
/// The method's parameters drive the generated inputSchema:
///   - A single @McpModel parameter → uses that model's schema
///   - Primitive parameters annotated with @McpParam → inline ObjectSchema
class McpTool {
  final String? path;
  final String description;

  const McpTool({this.path, required this.description});
}

/// Metadata for a primitive parameter of an @McpTool method.
///
/// Not needed for @McpModel parameters — those are self-describing.
class McpParam {
  final String description;
  final bool required;

  const McpParam({required this.description, this.required = true});
}


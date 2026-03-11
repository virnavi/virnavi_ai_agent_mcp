/// Marks a Dart class as an MCP model.
///
/// The generator produces an [ObjectSchema] for this class, respecting
/// @JsonKey(name:) overrides and @McpField metadata on each field.
///
/// [name] is optional. If provided it is used as the model's unique identifier
/// segment; if omitted the class name is used.
/// The full model ID is: `{package}/{name ?? ClassName}`
///
/// Example:
/// ```dart
/// @McpModel(name: 'create_task_input')
/// class CreateTaskInput {
///   @McpField(description: 'Task title')
///   final String title;
///   ...
/// }
/// ```
class McpModel {
  /// Optional name. Model ID = `{package}/{name ?? ClassName}`.
  final String? name;

  const McpModel({this.name});
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
///
/// [required] defaults to null, which means the generator infers required
/// status from the parameter type (non-nullable, no default → required).
/// Set explicitly to override: `@McpParam(description: '...', required: false)`.
class McpParam {
  final String description;

  /// When null (default), required is inferred from the parameter's type and
  /// default value. Set to true/false to override that inference.
  final bool? required;

  const McpParam({required this.description, this.required});
}

/// Put on a Flutter Widget class to bind it to an @McpModel.
///
/// The generator creates a static `fromStore()` method on an extension of
/// the annotated widget class. That method wraps [McpResultBuilder] and
/// automatically parses the bound model from the store — no boilerplate needed.
///
/// The widget's model ID (used as the [McpResultStore] key) is taken from the
/// @McpModel annotation on [model]: `{package}/{name ?? ClassName}`.
///
/// Example:
/// ```dart
/// @McpView(model: UserResult)
/// class UserCard extends StatelessWidget {
///   final UserResult data;
///   const UserCard({super.key, required this.data});
///   ...
/// }
///
/// // Usage (from generated extension):
/// UserCardMcpViewExtension.fromStore(
///   _store,
///   builder: (ctx, data) => UserCard(data: data),
/// )
/// ```
class McpView {
  /// The @McpModel type this widget is bound to.
  final Type model;

  const McpView({required this.model});
}

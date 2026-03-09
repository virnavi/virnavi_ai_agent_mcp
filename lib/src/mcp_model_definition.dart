import 'definition/schema.dart';

/// Runtime descriptor for an @McpModel class.
///
/// Generated in the `$ClassNameMcpX` accessor class via the `definition`
/// static getter. Pass instances to [McpSummary.bind] so the summary can
/// deserialize tool results without a manual switch statement.
class McpModelDefinition {
  /// The model's unique ID: `{package}/{name ?? ClassName}`.
  final String id;

  /// Returns the [ObjectSchema] for this model.
  final ObjectSchema Function() schemaFactory;

  /// Deserializes a JSON map into a model instance.
  /// The return type is [Object?] for type-erasure; callers cast as needed.
  final Object? Function(Map<String, dynamic>) fromJson;

  const McpModelDefinition({
    required this.id,
    required this.schemaFactory,
    required this.fromJson,
  });
}

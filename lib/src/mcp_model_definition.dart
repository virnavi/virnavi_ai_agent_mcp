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

  /// Definitions for any nested @McpModel types referenced by this model's
  /// fields. [McpSummary.bind] registers these automatically so callers never
  /// need to list nested models explicitly.
  final List<McpModelDefinition> nestedDefinitions;

  /// Extracts nested model JSON from a parent result map, keyed by nested
  /// model ID. Used by the compose layer to propagate nested model data into
  /// [McpResultStore] so widgets bound to nested models also react when a
  /// parent tool result arrives.
  ///
  /// Each value is a function `(parentJson) => nestedJson?` — returns `null`
  /// when the field is absent or null in the payload.
  final Map<String, Map<String, dynamic>? Function(Map<String, dynamic>)>
      nestedExtractors;

  const McpModelDefinition({
    required this.id,
    required this.schemaFactory,
    required this.fromJson,
    this.nestedDefinitions = const [],
    this.nestedExtractors = const {},
  });
}

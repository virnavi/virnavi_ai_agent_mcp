import '../result/resource_content.dart';

typedef ResourceReader = Future<ResourceContent> Function();

/// Defines a resource (app state, config, data) that an AI agent can read.
class ResourceDefinition {
  final String name;
  final String description;
  final String uri;
  final ResourceReader reader;

  const ResourceDefinition({
    required this.name,
    required this.description,
    required this.uri,
    required this.reader,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'uri': uri,
      };
}

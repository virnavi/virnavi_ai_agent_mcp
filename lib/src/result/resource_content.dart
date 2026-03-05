/// The content returned when an AI agent reads a resource.
class ResourceContent {
  final dynamic data;
  final String mimeType;

  const ResourceContent({required this.data, this.mimeType = 'application/json'});

  Map<String, dynamic> toJson() => {
        'mimeType': mimeType,
        'data': data,
      };
}

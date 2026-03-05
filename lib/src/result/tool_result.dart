/// The result returned by a tool handler.
class ToolResult {
  final dynamic data;
  final bool isError;
  final String? errorMessage;

  const ToolResult._({required this.data, required this.isError, this.errorMessage});

  /// Successful result. [data] can be any JSON-serializable value.
  factory ToolResult.success(dynamic data) =>
      ToolResult._(data: data, isError: false);

  /// Error result with a human-readable message.
  factory ToolResult.error(String message) =>
      ToolResult._(data: null, isError: true, errorMessage: message);

  Map<String, dynamic> toJson() => {
        'isError': isError,
        if (isError) 'error': errorMessage,
        if (!isError) 'data': data,
      };
}

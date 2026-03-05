/// Represents the lifecycle state of a single MCP tool invocation.
sealed class McpToolState {
  const McpToolState();
}

/// No invocation has occurred yet.
class McpIdle extends McpToolState {
  const McpIdle();
}

/// Tool is currently executing.
class McpLoading extends McpToolState {
  const McpLoading();
}

/// Tool completed successfully.
class McpSuccess extends McpToolState {
  final dynamic data;
  const McpSuccess(this.data);
}

/// Tool completed with an error.
class McpError extends McpToolState {
  final String message;
  const McpError(this.message);
}

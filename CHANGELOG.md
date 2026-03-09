## 0.0.1

Initial release.

- `AgentBridge` singleton — registers tools and resources, starts transports.
- `HttpTransport` — embedded JSON-RPC 2.0 HTTP server (`POST /mcp`), works in debug, profile, and release modes.
- `VmServiceTransport` — VM service extension transport for debug mode (zero config).
- `ToolRegistry` / `Dispatcher` — in-memory registry that routes AI agent calls to Flutter app handlers.
- Typed JSON Schema builders: `StringSchema`, `IntegerSchema`, `NumberSchema`, `BooleanSchema`, `ArraySchema`, `ObjectSchema`.
- `ToolResult` and `ResourceContent` result types.
- MCP annotations: `@McpModel`, `@McpField`, `@McpService`, `@McpTool`, `@McpParam`.
- Supported MCP methods: `tools/list`, `tools/call`, `resources/list`, `resources/read`.
- CORS headers on all responses for local MCP clients.
- Default HTTP host `127.0.0.1` (Android-safe).

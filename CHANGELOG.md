## 0.0.3

### New features

- **`McpModelDefinition.nestedDefinitions`** — list of `McpModelDefinition` for nested `@McpModel` types referenced by a model's fields. `McpSummary.bind()` now registers all nested definitions recursively, so callers never need to list them explicitly.
- **`McpModelDefinition.nestedExtractors`** — map of `modelId → (parentJson) → nestedJson?` functions. Used by the compose layer to automatically propagate nested model data into `McpResultStore` when a parent tool result arrives.
- **`McpSummary.bindViews()`** — default no-op stub added to the base class. The compose package overrides this via an extension; without compose, calling `bindWithViews()` no longer throws a compile error.

### Bug fixes

- **`@McpParam.required`** changed from `bool` (default `true`) to `bool?` (default `null`). When `null`, the generator infers required status from the parameter's nullability and presence of a default value. Previously, every `@McpParam(description: '...')` without an explicit `required: false` forced the parameter into the schema's `required` list regardless of its type.

---

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

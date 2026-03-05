import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

import 'mcp_result_store.dart';
import 'mcp_tool_state.dart';

/// Wraps a list of [ToolDefinition]s so that every invocation updates
/// [McpResultStore] automatically:
///
///   idle → loading → success(data) | error(message)
///
/// Use [bindTools] to get wrapped definitions ready for [AgentBridge].
class McpComposeBinding {
  final McpResultStore store;

  const McpComposeBinding(this.store);

  /// Returns new [ToolDefinition]s whose handlers drive [store] state.
  List<ToolDefinition> bindTools(List<ToolDefinition> tools) =>
      tools.map(_wrap).toList();

  ToolDefinition _wrap(ToolDefinition tool) {
    return ToolDefinition(
      name: tool.name,
      description: tool.description,
      inputSchema: tool.inputSchema,
      handler: (args) async {
        store.setState(tool.name, const McpLoading());
        try {
          final result = await tool.handler(args);
          final state = result.isError
              ? McpError(result.errorMessage ?? 'Unknown error')
              : McpSuccess(result.data);
          store.setState(tool.name, state);
          return result;
        } catch (e) {
          store.setState(tool.name, McpError(e.toString()));
          rethrow;
        }
      },
    );
  }
}

/// Convenience extension — bind and register in one call.
extension McpComposeBindingX on List<ToolDefinition> {
  /// Wraps every tool through [binding] and registers it on [bridge].
  void registerWith(AgentBridge bridge, McpComposeBinding binding) {
    for (final tool in binding.bindTools(this)) {
      bridge.registerTool(tool);
    }
  }
}

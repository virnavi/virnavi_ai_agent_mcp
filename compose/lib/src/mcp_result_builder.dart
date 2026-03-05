import 'package:flutter/widgets.dart';

import 'mcp_result_store.dart';
import 'mcp_tool_state.dart';

/// A widget that rebuilds whenever the state of [toolName] changes in [store].
///
/// Example:
/// ```dart
/// McpResultBuilder(
///   store: _store,
///   toolName: 'packages/my_app/mcp/tasks/list',
///   builder: (context, state) => switch (state) {
///     McpIdle()    => const Text('Waiting…'),
///     McpLoading() => const CircularProgressIndicator(),
///     McpSuccess(data: final d) => Text('$d'),
///     McpError(message: final m) => Text('Error: $m'),
///   },
/// )
/// ```
class McpResultBuilder extends StatelessWidget {
  final McpResultStore store;
  final String toolName;
  final Widget Function(BuildContext context, McpToolState state) builder;

  const McpResultBuilder({
    super.key,
    required this.store,
    required this.toolName,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => builder(context, store.stateOf(toolName)),
    );
  }
}

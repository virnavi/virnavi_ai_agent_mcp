import 'package:flutter/material.dart';
import 'package:virnavi_ai_agent_compose/virnavi_ai_agent_compose.dart';

/// The MCP tool names registered by TaskService.
const _packagePrefix = 'packages/virnavi_ai_agent_mcp_example/mcp/tasks';
const _tools = [
  ('list', '$_packagePrefix/list'),
  ('get', '$_packagePrefix/get'),
  ('create', '$_packagePrefix/create'),
  ('complete', '$_packagePrefix/complete'),
  ('delete', '$_packagePrefix/delete'),
  ('stats', '$_packagePrefix/stats'),
];

/// A collapsible bottom panel that uses [McpResultBuilder] to show the
/// live state of every registered MCP tool.
///
/// Demonstrates [virnavi_ai_agent_compose]: widgets rebuild reactively
/// whenever an AI agent invokes a tool, with no manual setState needed.
class AgentActivityPanel extends StatefulWidget {
  final McpResultStore store;

  const AgentActivityPanel({super.key, required this.store});

  @override
  State<AgentActivityPanel> createState() => _AgentActivityPanelState();
}

class _AgentActivityPanelState extends State<AgentActivityPanel> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_outlined, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Agent Activity',
                    style: theme.textTheme.labelLarge,
                  ),
                  const Spacer(),
                  // Show a loading indicator in the header if any tool is busy
                  McpResultBuilder(
                    store: widget.store,
                    toolName: _tools.first.$2,
                    builder: (_, __) => _AnyLoadingIndicator(
                      store: widget.store,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          // Tool rows
          if (_expanded) ...[
            const Divider(height: 1),
            for (final (label, toolName) in _tools)
              McpResultBuilder(
                key: ValueKey(toolName),
                store: widget.store,
                toolName: toolName,
                builder: (context, state) =>
                    _ToolRow(label: label, state: state),
              ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

/// Scans all tools and shows a spinner if any are loading.
class _AnyLoadingIndicator extends StatelessWidget {
  final McpResultStore store;
  const _AnyLoadingIndicator({required this.store});

  @override
  Widget build(BuildContext context) {
    final anyLoading = _tools.any(
      (t) => store.stateOf(t.$2) is McpLoading,
    );
    return anyLoading
        ? const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const SizedBox.shrink();
  }
}

class _ToolRow extends StatelessWidget {
  final String label;
  final McpToolState state;

  const _ToolRow({required this.label, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          _StatusDot(state: state),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _StateLabel(state: state)),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final McpToolState state;
  const _StatusDot({required this.state});

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      McpIdle() => const _Dot(color: Colors.grey),
      McpLoading() => const SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      McpSuccess() => const _Dot(color: Colors.green),
      McpError() => const _Dot(color: Colors.red),
    };
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) =>
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _StateLabel extends StatelessWidget {
  final McpToolState state;
  const _StateLabel({required this.state});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;

    return switch (state) {
      McpIdle() => Text('idle', style: style?.copyWith(color: Colors.grey)),
      McpLoading() => Text('calling…', style: style),
      McpSuccess(data: final d) => Text(
          _truncate('$d'),
          style: style?.copyWith(color: Colors.green.shade700),
          overflow: TextOverflow.ellipsis,
        ),
      McpError(message: final m) => Text(
          m,
          style: style?.copyWith(color: Colors.red.shade700),
          overflow: TextOverflow.ellipsis,
        ),
    };
  }

  static String _truncate(String s) =>
      s.length > 80 ? '${s.substring(0, 80)}…' : s;
}

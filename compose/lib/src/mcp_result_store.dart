import 'package:flutter/foundation.dart';

import 'mcp_tool_state.dart';

/// Holds the current [McpToolState] for every registered tool.
///
/// Notifies listeners whenever any tool's state changes, so widgets can
/// rebuild reactively.
class McpResultStore extends ChangeNotifier {
  final _states = <String, McpToolState>{};

  /// Returns the current state for [toolName], defaulting to [McpIdle].
  McpToolState stateOf(String toolName) =>
      _states[toolName] ?? const McpIdle();

  /// Updates the state for [toolName] and notifies listeners.
  void setState(String toolName, McpToolState state) {
    _states[toolName] = state;
    notifyListeners();
  }

  /// Resets a single tool back to [McpIdle].
  void reset(String toolName) => setState(toolName, const McpIdle());

  /// Resets all tools back to [McpIdle].
  void resetAll() {
    _states.clear();
    notifyListeners();
  }
}

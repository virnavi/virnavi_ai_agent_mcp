import 'package:flutter/material.dart';
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';
import 'package:virnavi_ai_agent_compose/virnavi_ai_agent_compose.dart';

import 'agent/task_service.dart';
import 'data/task_repository.dart';
import 'ui/agent_activity_panel.dart';
import 'ui/server_status_banner.dart';
import 'ui/task_list_screen.dart';

const _mcpPort = 8765;

/// Shared store — widgets read MCP call states from here.
final mcpStore = McpResultStore();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final service = TaskService(TaskRepository.instance);
  final binding = McpComposeBinding(mcpStore);

  AgentBridge.instance.initialize();
  await AgentBridge.instance.startHttpServer(port: _mcpPort);

  // Wrap tools through compose binding so mcpStore reflects every call.
  service.mcpTools.registerWith(AgentBridge.instance, binding);

  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager — MCP Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const _AppShell(),
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ServerStatusBanner(port: _mcpPort),
        const Expanded(child: TaskListScreen()),
        AgentActivityPanel(store: mcpStore),
      ],
    );
  }
}

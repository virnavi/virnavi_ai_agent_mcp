import 'package:flutter/material.dart';

/// Shows the MCP HTTP server address so the developer knows where to point the AI agent.
class ServerStatusBanner extends StatelessWidget {
  final int port;
  const ServerStatusBanner({super.key, required this.port});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.teal.shade700,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.hub, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'MCP server: http://127.0.0.1:$port/mcp',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

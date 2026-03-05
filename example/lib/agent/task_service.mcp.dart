// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_service.dart';

// **************************************************************************
// McpServiceGenerator
// **************************************************************************

extension TaskServiceMcpExtension on TaskService {
  List<ToolDefinition> get mcpTools => [
        ToolDefinition(
          name: 'packages/virnavi_ai_agent_mcp_example/mcp/tasks/list',
          description: 'Returns all tasks in the app.',
          inputSchema: ObjectSchema(),
          handler: (args) async {
            final result = await listTasks();
            return ToolResult.success(result.map((e) => e.toJson()).toList());
          },
        ),
        ToolDefinition(
          name: 'packages/virnavi_ai_agent_mcp_example/mcp/tasks/get',
          description: 'Returns a single task by its ID.',
          inputSchema: ObjectSchema(
            properties: {
              'id': StringSchema(description: 'The task ID'),
            },
            required: ['id'],
          ),
          handler: (args) async {
            final result = await getTask(args['id'] as String);
            return ToolResult.success(result?.toJson());
          },
        ),
        ToolDefinition(
          name: 'packages/virnavi_ai_agent_mcp_example/mcp/tasks/create',
          description: 'Creates a new task and adds it to the list.',
          inputSchema: $CreateTaskInputMcpX.schema(),
          handler: (args) async {
            final result = await createTask(CreateTaskInput.fromJson(args));
            return ToolResult.success(result.toJson());
          },
        ),
        ToolDefinition(
          name: 'packages/virnavi_ai_agent_mcp_example/mcp/tasks/complete',
          description: 'Marks a task as completed.',
          inputSchema: ObjectSchema(
            properties: {
              'id':
                  StringSchema(description: 'The task ID to mark as complete'),
            },
            required: ['id'],
          ),
          handler: (args) async {
            final result = await completeTask(args['id'] as String);
            return ToolResult.success(result);
          },
        ),
        ToolDefinition(
          name: 'packages/virnavi_ai_agent_mcp_example/mcp/tasks/delete',
          description: 'Deletes a task permanently.',
          inputSchema: ObjectSchema(
            properties: {
              'id': StringSchema(description: 'The task ID to delete'),
            },
            required: ['id'],
          ),
          handler: (args) async {
            final result = await deleteTask(args['id'] as String);
            return ToolResult.success(result);
          },
        ),
        ToolDefinition(
          name: 'packages/virnavi_ai_agent_mcp_example/mcp/tasks/stats',
          description: 'Returns task completion statistics.',
          inputSchema: ObjectSchema(),
          handler: (args) async {
            final result = await stats();
            return ToolResult.success(result);
          },
        ),
      ];
}

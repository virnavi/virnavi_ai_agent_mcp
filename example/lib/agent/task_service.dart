import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

import '../data/task_repository.dart';
import 'models.dart';

part 'task_service.mcp.dart';

@McpService(path: 'tasks')
class TaskService {
  final TaskRepository _repo;

  TaskService(this._repo);

  @McpTool(path: 'list', description: 'Returns all tasks in the app.')
  Future<List<Task>> listTasks() async => _repo.getAll().toList();

  @McpTool(path: 'get', description: 'Returns a single task by its ID.')
  Future<Task?> getTask(
    @McpParam(description: 'The task ID') String id,
  ) async => _repo.getById(id);

  @McpTool(path: 'create', description: 'Creates a new task and adds it to the list.')
  Future<Task> createTask(CreateTaskInput input) async => _repo.add(
        title: input.title,
        description: input.description ?? '',
      );

  @McpTool(path: 'complete', description: 'Marks a task as completed.')
  Future<bool> completeTask(
    @McpParam(description: 'The task ID to mark as complete') String id,
  ) async => _repo.complete(id);

  @McpTool(path: 'delete', description: 'Deletes a task permanently.')
  Future<bool> deleteTask(
    @McpParam(description: 'The task ID to delete') String id,
  ) async => _repo.delete(id);

  @McpTool(path: 'stats', description: 'Returns task completion statistics.')
  Future<Map<String, dynamic>> stats() async {
    final all = _repo.getAll();
    final done = all.where((t) => t.completed).length;
    return {'total': all.length, 'completed': done, 'pending': all.length - done};
  }
}

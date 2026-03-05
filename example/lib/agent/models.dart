import 'package:json_annotation/json_annotation.dart';
import 'package:virnavi_ai_agent_mcp/virnavi_ai_agent_mcp.dart';

part 'models.g.dart';
part 'models.mcp.dart';

@McpModel()
@JsonSerializable()
class Task {
  @McpField(description: 'Unique task ID')
  final String id;

  @McpField(description: 'Short title')
  final String title;

  @McpField(description: 'Details about the task')
  final String description;

  @McpField(description: 'Whether the task is completed')
  final bool completed;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

@McpModel()
@JsonSerializable()
class CreateTaskInput {
  @McpField(description: 'Short title for the task')
  final String title;

  @McpField(description: 'Details about the task')
  final String? description;

  const CreateTaskInput({required this.title, this.description});

  factory CreateTaskInput.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskInputFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTaskInputToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// McpModelGenerator
// **************************************************************************

ObjectSchema _$TaskToMcpSchema() {
  return ObjectSchema(
    properties: {
      'id': StringSchema(description: 'Unique task ID'),
      'title': StringSchema(description: 'Short title'),
      'description': StringSchema(description: 'Details about the task'),
      'completed': BooleanSchema(description: 'Whether the task is completed'),
    },
    required: ['id', 'title', 'description', 'completed'],
  );
}

// ignore: camel_case_types
class $TaskMcpX {
  static ObjectSchema schema() => _$TaskToMcpSchema();
}

ObjectSchema _$CreateTaskInputToMcpSchema() {
  return ObjectSchema(
    properties: {
      'title': StringSchema(description: 'Short title for the task'),
      'description': StringSchema(description: 'Details about the task'),
    },
    required: ['title'],
  );
}

// ignore: camel_case_types
class $CreateTaskInputMcpX {
  static ObjectSchema schema() => _$CreateTaskInputToMcpSchema();
}

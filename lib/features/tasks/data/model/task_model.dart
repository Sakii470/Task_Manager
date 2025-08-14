import 'dart:convert';

enum TaskStatus { inProgress, completed }

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final DateTime deadline;
  final TaskStatus status;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.deadline,
    required this.status,
  });
}

import 'dart:convert';

enum TaskStatus { inProgress, completed }

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime deadline;
  final TaskStatus status;

  const Task({required this.id, required this.title, this.description, required this.deadline, required this.status});

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'deadline': deadline.toIso8601String(),
    'status': status.index,
  };

  factory Task.fromMap(Map map) => Task(
    id: map['id'] as String,
    title: map['title'] as String,
    description: map['description'] as String?,
    deadline: DateTime.parse(map['deadline'] as String),
    status: TaskStatus.values[map['status'] as int],
  );
}

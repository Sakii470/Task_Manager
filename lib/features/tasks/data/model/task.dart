import 'dart:convert';

enum TaskStatus { inProgress, completed }

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime deadline;
  final TaskStatus status;
  final DateTime? completedDate;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.deadline,
    required this.status,
    this.completedDate,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'deadline': deadline.toIso8601String(),
    'status': status.index,
    'completedDate': completedDate?.toIso8601String(),
  };

  factory Task.fromMap(Map<String, Object?> map) => Task(
    id: map['id'] as String,
    title: map['title'] as String,
    description: map['description'] as String?,
    deadline: DateTime.parse(map['deadline'] as String),
    status: TaskStatus.values[map['status'] as int],
    completedDate: (map['completedDate'] as String?) != null && (map['completedDate'] as String?)!.isNotEmpty
        ? DateTime.parse(map['completedDate'] as String)
        : null,
  );

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    TaskStatus? status,
    DateTime? completedDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      completedDate: completedDate ?? this.completedDate,
    );
  }

  bool get isCompleted => status == TaskStatus.completed;
}

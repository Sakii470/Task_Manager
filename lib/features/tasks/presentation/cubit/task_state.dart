import 'package:task_manager/features/tasks/data/model/task.dart';

abstract class TaskState {
  const TaskState();
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  const TaskLoaded(this.tasks);
}

class TaskSubmitting extends TaskState {
  final List<Task> tasks;
  const TaskSubmitting(this.tasks);
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
}

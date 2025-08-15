import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:task_manager/features/tasks/domain/task_repo.dart';
import 'package:task_manager/features/tasks/data/model/task.dart';
import 'package:task_manager/features/tasks/presentation/cubit/task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final HiveTaskRepo repo;
  TaskCubit(this.repo) : super(const TaskInitial());

  // ---- Helpers added ----
  List<Task> get _currentTasks {
    final s = state;
    if (s is TaskLoaded) return s.tasks;
    if (s is TaskSubmitting) return s.tasks;
    return const [];
  }

  List<Task> _sorted(Iterable<Task> tasks) {
    final list = [...tasks];
    list.sort((a, b) => a.deadline.compareTo(b.deadline));
    return list;
  }

  Future<void> _mutation({
    required List<Task> Function(List<Task>) optimisticTransform,
    required Future<void> Function() action,
  }) async {
    final optimistic = _sorted(optimisticTransform(_currentTasks));
    emit(TaskSubmitting(optimistic));
    try {
      await action();
      // Always refetch for canonical state (keeps logic simple; can be optimized later)
      emit(TaskLoaded(_sorted(await repo.getAll())));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
  // ---- End helpers ----

  Future<void> loadTasks() async {
    emit(const TaskLoading());
    try {
      emit(TaskLoaded(_sorted(await repo.getAll())));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> addTask(Task task) async {
    // Optimistically append new task (assumes id already set; else still safe for UI)
    return _mutation(optimisticTransform: (list) => [...list, task], action: () => repo.create(task));
  }

  Future<void> updateTask(Task task) async {
    return _mutation(
      optimisticTransform: (list) => [
        for (final t in list)
          if (t.id == task.id) task else t,
      ],
      action: () => repo.update(task),
    );
  }

  Future<void> deleteTask(String id) async {
    return _mutation(
      optimisticTransform: (list) => [
        for (final t in list)
          if (t.id != id) t,
      ],
      action: () => repo.delete(id),
    );
  }
}

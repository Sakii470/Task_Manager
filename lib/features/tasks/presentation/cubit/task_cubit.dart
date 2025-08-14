import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:task_manager/features/tasks/domain/task_repo.dart';
import 'package:task_manager/features/tasks/data/model/task.dart';
import 'package:task_manager/features/tasks/presentation/cubit/task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final HiveTaskRepo repo;
  TaskCubit(this.repo) : super(const TaskInitial());

  Future<void> loadTasks() async {
    emit(const TaskLoading());
    try {
      final tasks = [...await repo.getAll()]..sort((a, b) => a.deadline.compareTo(b.deadline));
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> addTask(Task task) async {
    final prev = state is TaskLoaded
        ? (state as TaskLoaded).tasks
        : state is TaskSubmitting
        ? (state as TaskSubmitting).tasks
        : <Task>[];
    final submittingList = [...prev]..sort((a, b) => a.deadline.compareTo(b.deadline));
    emit(TaskSubmitting(submittingList));
    try {
      await repo.create(task);
      final tasks = [...await repo.getAll()]..sort((a, b) => a.deadline.compareTo(b.deadline));
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> updateTask(Task task) async {
    final prev = state is TaskLoaded
        ? (state as TaskLoaded).tasks
        : state is TaskSubmitting
        ? (state as TaskSubmitting).tasks
        : <Task>[];
    // optimistic local replace (sorted later after fetch)
    final optimistic = [
      for (final t in prev)
        if (t.id == task.id) task else t,
    ]..sort((a, b) => a.deadline.compareTo(b.deadline));
    emit(TaskSubmitting(optimistic));
    try {
      // Assumes repo has an update(task) method; adjust if different.
      await repo.update(task);
      final tasks = [...await repo.getAll()]..sort((a, b) => a.deadline.compareTo(b.deadline));
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  void printAll() {
    final s = state;
    if (s is TaskLoaded || s is TaskSubmitting) {
      final list = s is TaskLoaded ? s.tasks : (s as TaskSubmitting).tasks;
      debugPrint('--- Tasks (${list.length}) ---');
      for (final t in list) {
        debugPrint(
          'id=${t.id} | title=${t.title} | status=${t.status} | desc=${t.description} | deadline=${t.deadline.toIso8601String()}',
        );
      }
      debugPrint('------------------------');
    } else {
      debugPrint('No tasks to print (state=$s)');
    }
  }

  void sortByDeadline({bool ascending = true}) {
    // Retained for potential manual triggers elsewhere (now unused in screen)
    final current = state;
    if (current is TaskLoaded) {
      final sorted = [...current.tasks]
        ..sort((a, b) => ascending ? a.deadline.compareTo(b.deadline) : b.deadline.compareTo(a.deadline));
      emit(TaskLoaded(sorted));
    } else if (current is TaskSubmitting) {
      final sorted = [...current.tasks]
        ..sort((a, b) => ascending ? a.deadline.compareTo(b.deadline) : b.deadline.compareTo(a.deadline));
      emit(TaskSubmitting(sorted));
    }
  }
}

// no-op for other states

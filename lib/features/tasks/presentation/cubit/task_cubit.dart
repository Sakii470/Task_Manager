import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:task_manager/features/tasks/domain/task_repo.dart';
import 'package:task_manager/features/tasks/data/model/task.dart';
import 'package:task_manager/features/tasks/presentation/cubit/task_state.dart';
import 'package:task_manager/core/notifications/noti_service.dart';

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

  // helper to check if a DateTime is today (calendar date)
  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  // run notifications only once per app session (first load)
  // made static so it survives TaskCubit recreation during the same process
  static bool _startupNotificationSent = false;

  Future<void> loadTasks() async {
    emit(const TaskLoading());
    try {
      final all = await repo.getAll();
      final sorted = _sorted(all);
      emit(TaskLoaded(sorted));

      // run notifications only the first time loadTasks is called after app start
      if (!TaskCubit._startupNotificationSent) {
        TaskCubit._startupNotificationSent = true;
        // After tasks are loaded, notify for tasks whose deadline is today
        try {
          // collect today's tasks (only unfinished ones)
          final todays = [
            for (final t in sorted)
              if (t.deadline != null && _isToday(t.deadline) && t.completedDate == null) t,
          ];

          if (todays.isNotEmpty) {
            String _formatDt(DateTime dt) {
              final y = dt.year.toString().padLeft(4, '0');
              final m = dt.month.toString().padLeft(2, '0');
              final d = dt.day.toString().padLeft(2, '0');
              final hh = dt.hour.toString().padLeft(2, '0');
              final mm = dt.minute.toString().padLeft(2, '0');
              return '$y-$m-$d $hh:$mm';
            }

            final buffer = StringBuffer();
            for (var i = 0; i < todays.length; i++) {
              final t = todays[i];
              final dl = t.deadline!;
              buffer.writeln('${i + 1}. Title: ${t.title ?? 'Untitled'} | Deadline: ${_formatDt(dl)}');
            }

            NotiService().showNotification(title: 'Tasks due today (${todays.length})', body: buffer.toString().trim());
          }
        } catch (_) {
          // swallow notification errors so loadTasks doesn't fail
        }
      }
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

  // New: mark task as done (set status to completed and completedDate = now)
  Future<void> markTaskDone(Task task) async {
    final updated = task.copyWith(status: TaskStatus.completed, completedDate: DateTime.now());
    return updateTask(updated);
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

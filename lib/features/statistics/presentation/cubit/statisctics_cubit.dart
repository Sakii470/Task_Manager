import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:task_manager/features/tasks/domain/task_repo.dart';
import 'package:task_manager/features/tasks/data/model/task.dart'; // added

part 'statisctics_state.dart';

class StatiscticsCubit extends Cubit<StatiscticsState> {
  final HiveTaskRepo repo;
  StatiscticsCubit(this.repo) : super(StatiscticsInitial());

  // Fetch statistics and emit states
  Future<void> loadStatistics() async {
    emit(StatiscticsLoading());
    try {
      final tasks = await _safeGetTasks();
      int completed = 0;
      for (final t in tasks) {
        if (_isTaskCompleted(t)) completed++;
      }

      emit(StatiscticsLoaded(completed: completed));
    } catch (e) {
      emit(StatiscticsError(e?.toString() ?? 'Unknown error'));
    }
  }

  // Call the repo API directly and return typed list
  Future<List<Task>> _safeGetTasks() async {
    try {
      // prefer the well-known method on the repo
      final items = await repo.getAll(includeCompleted: true);
      return items;
    } catch (_) {
      return <Task>[];
    }
  }

  bool _isTaskCompleted(Task t) {
    return t.isCompleted;
  }
}

import 'package:task_manager/features/tasks/data/model/task.dart';

abstract class HiveTaskRepo {
  Future<List<Task>> getAll({bool includeCompleted = true});
  Future<Task> create(Task task);
  Future<Task> update(Task task);
  Future<void> delete(String id);
}

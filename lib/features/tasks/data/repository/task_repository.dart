import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/task_repo.dart';
import '../model/task.dart';

class HiveTaskRepository implements HiveTaskRepo {
  static const _boxName = 'tasks';
  late final Box<Map> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_boxName);
  }

  @override
  Future<List<Task>> getAll({bool includeCompleted = true}) async {
    final items = _box.values
        .map((m) => Task.fromMap(m.cast<String, Object?>()))
        .where((t) => includeCompleted || t.status != TaskStatus.completed)
        .toList();
    return items;
  }

  @override
  Future<Task> create(Task task) async {
    await _box.put(task.id, task.toMap());
    // ignore: avoid_print
    print(
      'Created task ${task.id} | ${task.title} | status=${task.status} | desc=${task.description} | deadline=${task.deadline.toIso8601String()}',
    );
    return task;
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
    // ignore: avoid_print
    print('Deleted task $id');
  }

  @override
  Future<Task> update(Task task) async {
    if (!_box.containsKey(task.id)) {
      throw StateError('Task not found');
    }
    await _box.put(task.id, task.toMap());
    // ignore: avoid_print
    print(
      'Updated task ${task.id} | ${task.title} | status=${task.status} | desc=${task.description} | deadline=${task.deadline.toIso8601String()} | completedDate=${task.completedDate?.toIso8601String()}',
    );
    return task;
  }
}

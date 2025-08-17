import 'package:get_it/get_it.dart';
import 'package:task_manager/features/tasks/data/repository/task_repository.dart';
import 'package:task_manager/features/tasks/domain/task_repo.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  if (!getIt.isRegistered<HiveTaskRepository>()) {
    final repo = HiveTaskRepository();
    await repo.init();

    getIt..registerSingleton<HiveTaskRepo>(repo);
  }
}

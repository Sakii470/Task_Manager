import 'package:get_it/get_it.dart';
import 'features/tasks/data/repository/task_repository.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  locator.registerSingletonAsync<HiveTaskRepository>(() async {
    final repo = HiveTaskRepository();
    await repo.init();
    return repo;
  });

  await locator.allReady();
}

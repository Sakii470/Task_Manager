import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/app/di/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/tasks/domain/task_repo.dart';
import 'package:task_manager/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:task_manager/features/tasks/presentation/cubit/task_state.dart';
import 'app/router/app_router.dart';

void main() async {
  GoRouter.optionURLReflectsImperativeAPIs = true;
  WidgetsFlutterBinding.ensureInitialized();

  await setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final _router = createGoRouter();
    return MultiBlocProvider(
      providers: [BlocProvider<TaskCubit>(create: (_) => TaskCubit(getIt<HiveTaskRepo>())..loadTasks())],
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            surface: Colors.grey.shade300,
            onSurface: Colors.black,
            primary: Colors.blue,
            onPrimary: Colors.white,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'home_shell.dart';
import 'package:task_manager/features/tasks/presentation/screens/task_screen.dart';
import 'package:task_manager/features/statistics/presentation/screens/statistics_screen.dart';

GoRouter createGoRouter() {
  return GoRouter(
    initialLocation: '/tasks',
    routes: [
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child, location: state.uri.toString()),
        routes: [
          GoRoute(path: '/tasks', builder: (context, state) => const TaskScreen()),
          GoRoute(path: '/statistics', builder: (context, state) => const StatisticsScreen()),
        ],
      ),
    ],
  );
}

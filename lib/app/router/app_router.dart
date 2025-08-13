import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/features/tasks/presentation/screens/task_screen.dart';

GoRouter createGoRouter() {
  return GoRouter(
    initialLocation: '/tasks',
    routes: [
      GoRoute(
        path: '/tasks',
        builder: (context, state) => const TaskScreen(), // Replace with your home widget
      ),
      // ...add more routes here...
    ],
  );
}

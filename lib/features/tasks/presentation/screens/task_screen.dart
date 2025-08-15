import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/components/custom_header.dart';
import 'package:task_manager/components/background_pattern.dart';
import 'package:task_manager/app/di/service_locator.dart';
import 'package:task_manager/features/tasks/data/model/task.dart';
import 'package:task_manager/features/tasks/domain/task_repo.dart';
import 'package:task_manager/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:task_manager/features/tasks/presentation/cubit/task_state.dart'
    show TaskState, TaskLoading, TaskInitial, TaskError, TaskSubmitting, TaskLoaded;
import 'package:task_manager/features/tasks/presentation/screens/add_task_sheet.dart';
import 'package:task_manager/features/tasks/presentation/widgets/task_card.dart' show TaskCard;
import 'package:task_manager/app/theme/app_colors.dart' as app_colors;

class TaskScreen extends StatelessWidget {
  const TaskScreen({Key? key}) : super(key: key);

  void _openAddTaskPopup(BuildContext context, {Task? task}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(heightFactor: 0.75, child: AddTaskSheet(initialTask: task)),
    );
    if (saved == true && context.mounted) {
      context.read<TaskCubit>().loadTasks(); // Reload tasks after adding/updating
      final isAdd = task == null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAdd ? 'Task added' : 'Task updated'),
          backgroundColor: isAdd ? Colors.green : app_colors.orange1,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskCubit>(
      create: (_) => TaskCubit(getIt.isRegistered<HiveTaskRepo>() ? getIt<HiveTaskRepo>() : getIt())..loadTasks(),
      // Using Builder to access provided cubit context
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: const CustomHeader(title: 'Tasks', showBackArrow: false),
            body: BackgroundPattern(
              child: Padding(
                // was Center(...)
                padding: const EdgeInsets.all(16),
                child: BlocBuilder<TaskCubit, TaskState>(
                  builder: (context, state) {
                    if (state is TaskLoading || state is TaskInitial) {
                      return const CircularProgressIndicator();
                    }
                    if (state is TaskError) {
                      return Text('Error: ${state.message}');
                    }
                    final isSubmitting = state is TaskSubmitting;
                    final tasks = state is TaskLoaded
                        ? state.tasks
                        : state is TaskSubmitting
                        ? state.tasks
                        : <Task>[];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max, // fill vertical
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (_, i) => TaskCard(
                              task: tasks[i],
                              onEdit: () => _openAddTaskPopup(context, task: tasks[i]),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _openAddTaskPopup(context),
              backgroundColor: app_colors.blue1,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/components/custom_header.dart';
import 'package:task_manager/components/background_pattern.dart';
import 'package:task_manager/app/di/service_locator.dart';
import 'package:task_manager/core/notifications/noti_service.dart';
import 'package:task_manager/features/tasks/data/model/task.dart';
import 'package:task_manager/features/tasks/domain/task_repo.dart';
import 'package:task_manager/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:task_manager/features/tasks/presentation/cubit/task_state.dart'
    show TaskState, TaskLoading, TaskInitial, TaskError, TaskSubmitting, TaskLoaded;
import 'package:task_manager/features/tasks/presentation/widgets/add_task_sheet.dart';
import 'package:task_manager/features/tasks/presentation/widgets/task_card.dart' show TaskCard;
import 'package:task_manager/features/tasks/presentation/widgets/task_section.dart';
import 'package:task_manager/app/theme/app_colors.dart' as app_colors;

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  bool showActiveTasks = true;
  bool showDoneTasks = true;

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
                padding: const EdgeInsets.only(left: 16, right: 16),
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

                    // Split tasks into active and done (tolerant check so enum or string works)
                    final doneTasks =
                        tasks.where((t) {
                            final s = t.status?.toString().toLowerCase() ?? '';
                            return s.contains('completed');
                          }).toList()
                          // sort by completedDate desc (tasks completed most recently appear first)
                          ..sort((a, b) {
                            final ad = a.completedDate;
                            final bd = b.completedDate;
                            if (ad == null && bd == null) return 0;
                            if (ad == null) return 1; // push nulls to the end
                            if (bd == null) return -1;
                            return bd.compareTo(ad); // newer (closer to now) first
                          });
                    final activeTasks = tasks.where((t) {
                      final s = t.status?.toString().toLowerCase() ?? '';
                      return !s.contains('completed');
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max, // fill vertical
                      children: [
                        // Use a single scrollable area that contains both sections
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 8),

                                TaskSection(
                                  title: 'Active tasks',
                                  color: app_colors.blue1,
                                  tasks: activeTasks,
                                  expanded: showActiveTasks,
                                  onToggle: () => setState(() => showActiveTasks = !showActiveTasks),
                                  itemBuilder: (t) => TaskCard(
                                    task: t,
                                    onEdit: () => _openAddTaskPopup(context, task: t),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                TaskSection(
                                  title: 'Done tasks',
                                  color: app_colors.green1,
                                  tasks: doneTasks,
                                  expanded: showDoneTasks,
                                  onToggle: () => setState(() => showDoneTasks = !showDoneTasks),
                                  itemBuilder: (t) => TaskCard(
                                    task: t,
                                    onEdit: () => _openAddTaskPopup(context, task: t),
                                    //onMarkDone: null,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
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

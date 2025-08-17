//This card is used in /studio/tickets

import 'package:flutter/material.dart';
import 'package:task_manager/app/theme/app_colors.dart' as app_colors;
import 'package:task_manager/features/tasks/data/model/task.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:task_manager/features/tasks/presentation/widgets/task_done_button.dart'; // added import

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onEdit;

  const TaskCard({required this.task, this.onEdit, Key? key}) : super(key: key);

  String _formatDeadline(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  int _daysToDeadline(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(deadline.year, deadline.month, deadline.day);
    return dateOnly.difference(today).inDays;
  }

  Color _deadlineLabelColor(DateTime deadline) {
    final days = _daysToDeadline(deadline);
    if (days <= 0) return app_colors.red1;
    if (days > 0 && days <= 3) return app_colors.orange1;
    return app_colors.blue1;
  }

  String _deadlineLabel(DateTime deadline) => 'Deadline: ${_formatDeadline(deadline)}';

  @override
  Widget build(BuildContext context) {
    final labelColor = task.completedDate != null ? app_colors.green1 : _deadlineLabelColor(task.deadline);
    final deadlineText = task.completedDate != null
        ? 'Done: ${_formatDeadline(task.completedDate!)}'
        : _deadlineLabel(task.deadline);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: app_colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: labelColor, width: 6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: labelColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), bottomRight: Radius.circular(12)),
                ),
                child: Text(
                  deadlineText,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: const [
                      Text(
                        "Edit",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.edit, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Body
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Task: ${task.title}",
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                    ),
                    // Only show "Task Done" button for tasks that are not completed
                    if (task.completedDate == null) ...[
                      const SizedBox(width: 24),
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: TaskDoneButton(onPressed: () => context.read<TaskCubit>().markTaskDone(task)),
                      ),
                    ],
                  ],
                ),
                if (task.description != null && task.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description!.trim(),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      letterSpacing: 0,
                      height: 1.2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

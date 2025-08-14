//This card is used in /studio/tickets

import 'package:flutter/material.dart';
import 'package:task_manager/app/theme/app_colors.dart' as app_colors;
import 'package:task_manager/features/tasks/data/model/task.dart';

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
    if (days == 0) return app_colors.red1;
    if (days > 0 && days <= 3) return app_colors.orange1;
    return app_colors.blue1;
  }

  String _deadlineLabel(DateTime deadline) => 'Deadline: ${_formatDeadline(deadline)}';

  @override
  Widget build(BuildContext context) {
    final labelColor = _deadlineLabelColor(task.deadline);
    final deadlineText = _deadlineLabel(task.deadline);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: app_colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header stripe
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: labelColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Task: ${task.title}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: 0,
                    height: 1.1, // tighter line height
                  ),
                ),
                if (task.description != null && task.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4), // reduced from 6
                  Text(
                    task.description!.trim(),
                    maxLines: 3,
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

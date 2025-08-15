import 'package:flutter/material.dart';
import 'package:task_manager/app/theme/app_colors.dart' as app_colors;
import 'package:task_manager/features/tasks/data/model/task.dart';

class TaskSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<Task> tasks;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget Function(Task task) itemBuilder;

  const TaskSection({
    Key? key,
    required this.title,
    required this.color,
    required this.tasks,
    required this.expanded,
    required this.onToggle,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: app_colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
                Chip(label: Text('${tasks.length}'), backgroundColor: color.withOpacity(0.12)),
                const SizedBox(width: 8),
                Icon(expanded ? Icons.expand_less : Icons.expand_more, color: color),
              ],
            ),
          ),
          if (expanded) const SizedBox(height: 8),
          if (expanded)
            if (tasks.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('No tasks'))
            else
              ...tasks.map((t) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: itemBuilder(t))),
        ],
      ),
    );
  }
}

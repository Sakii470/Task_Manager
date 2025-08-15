import 'package:flutter/material.dart';
import 'package:task_manager/app/theme/app_colors.dart' as app_colors;

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  const StatCard({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: app_colors.green2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: app_colors.green1, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

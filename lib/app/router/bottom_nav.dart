import 'package:flutter/material.dart';
import 'package:task_manager/app/theme/app_colors.dart' as app_colors;

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const BottomNav({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white, // force white background
      type: BottomNavigationBarType.fixed,
      selectedItemColor: app_colors.blue1,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.checklist_outlined), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.query_stats_outlined), label: 'Statistics'),
      ],
    );
  }
}

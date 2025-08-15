import 'package:flutter/material.dart';
import 'package:task_manager/app/theme/app_colors.dart' as app_colors;

/// WeekBarChart widget moved from statistics_screen.dart
class WeekBarChart extends StatelessWidget {
  final List<int> counts;
  const WeekBarChart({required this.counts, super.key});

  @override
  Widget build(BuildContext context) {
    final maxCount = counts.isEmpty ? 0 : counts.reduce((a, b) => a > b ? a : b);
    // total area reserved for bars & value text
    final totalBarArea = 120.0;
    // reserve a small bottom gap so bars won't touch/overflow the card (about 15-16px)
    const reservedBottomSpace = 16.0;
    // reserve vertical space for the small value label under each bar
    const valueLabelHeight = 18.0;
    final availableBarHeight = totalBarArea - reservedBottomSpace - valueLabelHeight;
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final textColor = Colors.black87;
    final weekTotal = counts.isEmpty ? 0 : counts.reduce((a, b) => a + b);

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Weekly completed tasks', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(color: app_colors.backgroundColor, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    weekTotal.toString(),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: app_colors.blue1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: totalBarArea,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final value = counts.length > i ? counts[i] : 0;
                  final height = (maxCount == 0) ? 0.0 : (value / maxCount) * availableBarHeight;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: height,
                            width: double.infinity,
                            decoration: BoxDecoration(color: app_colors.blue1, borderRadius: BorderRadius.circular(6)),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: valueLabelHeight,
                            child: Center(
                              child: Text(value.toString(), style: TextStyle(fontSize: 12, color: textColor)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(7, (i) {
                return Expanded(
                  child: Center(
                    child: Text(labels[i], style: TextStyle(fontSize: 12, color: app_colors.black1)),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

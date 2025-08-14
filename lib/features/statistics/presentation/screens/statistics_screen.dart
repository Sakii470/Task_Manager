import 'package:flutter/material.dart';
import 'package:task_manager/components/custom_header.dart';
import 'package:task_manager/components/background_pattern.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(title: 'Statistics', showBackArrow: false),
      body: BackgroundPattern(
        showBottomLinearGradient: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _StatCard(title: 'Completed Tasks', value: '42'),
            SizedBox(height: 12),
            _StatCard(title: 'Pending Tasks', value: '7'),
            SizedBox(height: 12),
            _StatCard(title: 'Completion Rate', value: '86%'),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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

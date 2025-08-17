import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/components/custom_header.dart';
import 'package:task_manager/components/background_pattern.dart';
import 'package:task_manager/features/statistics/presentation/widgets/stat_card.dart';
import 'package:task_manager/features/statistics/presentation/cubit/statisctics_cubit.dart';
import 'package:task_manager/features/tasks/domain/task_repo.dart';
import 'package:task_manager/features/tasks/data/model/task.dart';
import 'package:task_manager/features/statistics/presentation/widgets/week_bar_chart.dart';
import 'package:task_manager/app/theme/app_colors.dart' as app_colors;

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskRepo = GetIt.instance<HiveTaskRepo>();

    return BlocProvider(
      create: (_) => StatiscticsCubit(taskRepo)..loadStatistics(),
      child: Scaffold(
        appBar: const CustomHeader(title: 'Statistics'),
        body: BackgroundPattern(
          showBottomLinearGradient: true,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<StatiscticsCubit, StatiscticsState>(
              builder: (context, state) {
                // initial / loading
                if (state is StatiscticsLoading || state is StatiscticsInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                // error
                if (state is StatiscticsError) {
                  return Center(child: Text(state.message));
                }
                // loaded
                if (state is StatiscticsLoaded) {
                  return ListView(
                    children: [
                      StatCard(title: 'Completed Tasks', value: '${state.completed}'),
                      const SizedBox(height: 12),
                      FutureBuilder<List<Task>>(
                        future: taskRepo.getAll(includeCompleted: true),
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return const SizedBox(height: 140, child: Center(child: CircularProgressIndicator()));
                          }
                          if (snap.hasError) {
                            return SizedBox(height: 140, child: Center(child: Text('Error: ${snap.error}')));
                          }
                          final allTasks = snap.data ?? <Task>[];
                          final weekCounts = _computeWeeklyCounts(allTasks);
                          return WeekBarChart(counts: weekCounts);
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  List<int> _computeWeeklyCounts(List<Task> tasks) {
    final counts = List<int>.filled(7, 0);
    for (final t in tasks) {
      final isCompleted = t.isCompleted;
      if (!isCompleted) continue;
      final dt = t.completedDate ?? DateTime.now();
      final idx = (dt.weekday - 1).clamp(0, 6);
      counts[idx] = counts[idx] + 1;
    }
    return counts;
  }
}

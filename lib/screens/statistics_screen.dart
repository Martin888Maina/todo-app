import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);
    final total = tasks.length;
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final pendingCount = total - completedCount;
    final rate = total == 0 ? 0.0 : completedCount / total;

    // Category counts
    final categories = ['work', 'personal', 'shopping', 'health', 'other'];
    final categoryLabels = {
      'work': AppStrings.work,
      'personal': AppStrings.personal,
      'shopping': AppStrings.shopping,
      'health': AppStrings.health,
      'other': AppStrings.other,
    };
    final categoryColors = {
      'work': AppColors.categoryWork,
      'personal': AppColors.categoryPersonal,
      'shopping': AppColors.categoryShopping,
      'health': AppColors.categoryHealth,
      'other': AppColors.categoryOther,
    };

    // Priority counts
    final priorities = ['high', 'medium', 'low'];
    final priorityLabels = {
      'high': AppStrings.high,
      'medium': AppStrings.medium,
      'low': AppStrings.low,
    };
    final priorityColors = {
      'high': AppColors.priorityHigh,
      'medium': AppColors.priorityMedium,
      'low': AppColors.priorityLow,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.statistics),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Completion ring
            Center(
              child: _CompletionRing(rate: rate, completed: completedCount, total: total),
            ),
            const SizedBox(height: 28),

            // Summary cards row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: AppStrings.totalTasks,
                    value: '$total',
                    color: AppColors.primary,
                    icon: Icons.list_alt_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: AppStrings.completedTasks,
                    value: '$completedCount',
                    color: AppColors.priorityLow,
                    icon: Icons.task_alt_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: AppStrings.pendingTasks,
                    value: '$pendingCount',
                    color: AppColors.priorityMedium,
                    icon: Icons.hourglass_bottom_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // By category
            const _SectionHeader(label: AppStrings.byCategory),
            const SizedBox(height: 12),
            ...categories.map((cat) {
              final count = tasks.where((t) => t.category == cat).length;
              return _BarRow(
                label: categoryLabels[cat]!,
                count: count,
                total: total,
                color: categoryColors[cat]!,
              );
            }),
            const SizedBox(height: 28),

            // By priority
            const _SectionHeader(label: AppStrings.byPriority),
            const SizedBox(height: 12),
            ...priorities.map((p) {
              final count = tasks.where((t) => t.priority == p).length;
              return _BarRow(
                label: priorityLabels[p]!,
                count: count,
                total: total,
                color: priorityColors[p]!,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CompletionRing extends StatelessWidget {
  final double rate;
  final int completed;
  final int total;

  const _CompletionRing({
    required this.rate,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: rate,
                strokeWidth: 12,
                backgroundColor: AppColors.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(rate * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    AppStrings.completionRate,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$completed of $total tasks completed',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _BarRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: AppColors.surface,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

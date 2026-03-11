import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/date_helpers.dart';
import '../widgets/task_form.dart';

class TaskDetailScreen extends ConsumerWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  Color _priorityColor() {
    switch (task.priority) {
      case 'high':
        return AppColors.priorityHigh;
      case 'low':
        return AppColors.priorityLow;
      default:
        return AppColors.priorityMedium;
    }
  }

  String _priorityLabel() {
    switch (task.priority) {
      case 'high':
        return AppStrings.high;
      case 'low':
        return AppStrings.low;
      default:
        return AppStrings.medium;
    }
  }

  Color _categoryColor() {
    switch (task.category) {
      case 'work':
        return AppColors.categoryWork;
      case 'shopping':
        return AppColors.categoryShopping;
      case 'health':
        return AppColors.categoryHealth;
      case 'other':
        return AppColors.categoryOther;
      default:
        return AppColors.categoryPersonal;
    }
  }

  String _categoryLabel() {
    switch (task.category) {
      case 'work':
        return AppStrings.work;
      case 'shopping':
        return AppStrings.shopping;
      case 'health':
        return AppStrings.health;
      case 'other':
        return AppStrings.other;
      default:
        return AppStrings.personal;
    }
  }

  void _openEditForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => TaskForm(existingTask: task),
    );
  }

  Future<void> _deleteTask(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteTask),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.priorityHigh),
            child: const Text(AppStrings.deleteTask),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(taskProvider.notifier).deleteTask(task.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue = DateHelpers.isOverdue(task.dueDate, task.isCompleted);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _openEditForm(context),
            tooltip: AppStrings.editTask,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteTask(context, ref),
            tooltip: AppStrings.deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with completion checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: task.isCompleted,
                  activeColor: AppColors.primary,
                  onChanged: (_) {
                    ref.read(taskProvider.notifier).toggleCompletion(task.id);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted
                            ? AppColors.textCompleted
                            : AppColors.textPrimary,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Meta chips row
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                // Priority chip
                _MetaChip(
                  label: _priorityLabel(),
                  color: _priorityColor(),
                  icon: Icons.flag_outlined,
                ),
                // Category chip
                _MetaChip(
                  label: _categoryLabel(),
                  color: _categoryColor(),
                  icon: Icons.label_outline,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Due date
            if (task.dueDate != null) ...[
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: AppStrings.dueDate,
                value: DateHelpers.full(task.dueDate!),
                valueColor: isOverdue ? AppColors.overdueRed : null,
                trailing: isOverdue
                    ? const _Badge(label: AppStrings.overdue, color: AppColors.overdueRed)
                    : null,
              ),
              const SizedBox(height: 12),
            ],

            // Created timestamp
            _DetailRow(
              icon: Icons.access_time_outlined,
              label: 'Created',
              value: DateHelpers.relative(task.createdAt),
            ),
            const SizedBox(height: 20),

            // Description / notes
            if (task.description != null && task.description!.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.description!,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _MetaChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

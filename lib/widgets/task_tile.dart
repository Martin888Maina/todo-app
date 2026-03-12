import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';

// Displays a single task row with priority indicator, category chip, and due date
class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

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

  bool get _isOverdue {
    if (task.dueDate == null || task.isCompleted) return false;
    final today = DateTime.now();
    return task.dueDate!.isBefore(DateTime(today.year, today.month, today.day));
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      // Swipe left = delete, swipe right = toggle complete
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: AppColors.primary,
        child: Icon(
          task.isCompleted ? Icons.undo : Icons.check_circle_outline,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.priorityHigh,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right toggles completion without removing the tile
          onToggle();
          return false;
        }
        // Swipe left confirms deletion
        return true;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Priority indicator — coloured left border
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: _priorityColor(),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Semantics(
                          label: task.isCompleted
                              ? 'Mark ${task.title} incomplete'
                              : 'Mark ${task.title} complete',
                          child: Checkbox(
                            value: task.isCompleted,
                            activeColor: AppColors.primary,
                            onChanged: (_) => onToggle(),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: task.isCompleted
                                      ? AppColors.textCompleted
                                      : Theme.of(context).colorScheme.onSurface,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  // Category chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _categoryColor().withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _categoryLabel(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _categoryColor(),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (task.dueDate != null) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.calendar_today,
                                      size: 11,
                                      color: _isOverdue
                                          ? AppColors.overdueRed
                                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      _isOverdue
                                          ? AppStrings.overdue
                                          : DateFormat('MMM d').format(task.dueDate!),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _isOverdue
                                            ? AppColors.overdueRed
                                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                        fontWeight: _isOverdue
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              // Subtask progress bar — only shown when subtasks exist
                              if ((task.subtasks ?? []).isNotEmpty) ...[
                                const SizedBox(height: 6),
                                _SubtaskProgress(subtasks: task.subtasks!),
                              ],
                            ],
                          ),
                        ),
                        // Drag handle — used by ReorderableListView in home screen
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.drag_handle,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubtaskProgress extends StatelessWidget {
  final List<SubTask> subtasks;

  const _SubtaskProgress({required this.subtasks});

  @override
  Widget build(BuildContext context) {
    final done = subtasks.where((s) => s.isCompleted).length;
    final fraction = subtasks.isEmpty ? 0.0 : done / subtasks.length;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 4,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$done/${subtasks.length}',
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

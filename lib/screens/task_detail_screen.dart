import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/date_helpers.dart';
import '../widgets/task_form.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _subtaskController = TextEditingController();
  final _uuid = const Uuid();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  Task get _task => widget.task;

  Color _priorityColor() {
    switch (_task.priority) {
      case 'high':
        return AppColors.priorityHigh;
      case 'low':
        return AppColors.priorityLow;
      default:
        return AppColors.priorityMedium;
    }
  }

  String _priorityLabel() {
    switch (_task.priority) {
      case 'high':
        return AppStrings.high;
      case 'low':
        return AppStrings.low;
      default:
        return AppStrings.medium;
    }
  }

  Color _categoryColor() {
    switch (_task.category) {
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
    switch (_task.category) {
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

  void _openEditForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => TaskForm(existingTask: _task),
    );
  }

  Future<void> _deleteTask() async {
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

    if (confirmed == true && mounted) {
      await ref.read(taskProvider.notifier).deleteTask(_task.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _addSubtask() async {
    final title = _subtaskController.text.trim();
    if (title.isEmpty) return;

    final subtask = SubTask(id: _uuid.v4(), title: title);
    _task.subtasks = [...(_task.subtasks ?? []), subtask];
    await ref.read(taskProvider.notifier).updateTask(_task);

    _subtaskController.clear();
    setState(() {});
  }

  Future<void> _toggleSubtask(SubTask subtask) async {
    subtask.isCompleted = !subtask.isCompleted;
    await ref.read(taskProvider.notifier).updateTask(_task);
    setState(() {});
  }

  Future<void> _deleteSubtask(SubTask subtask) async {
    _task.subtasks = (_task.subtasks ?? [])
        .where((s) => s.id != subtask.id)
        .toList();
    await ref.read(taskProvider.notifier).updateTask(_task);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = DateHelpers.isOverdue(_task.dueDate, _task.isCompleted);
    final subtasks = _task.subtasks ?? [];
    final completedSubs = subtasks.where((s) => s.isCompleted).length;
    final subProgress = subtasks.isEmpty ? 0.0 : completedSubs / subtasks.length;

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
            onPressed: _openEditForm,
            tooltip: AppStrings.editTask,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteTask,
            tooltip: AppStrings.deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with completion toggle
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _task.isCompleted,
                  activeColor: AppColors.primary,
                  onChanged: (_) {
                    ref.read(taskProvider.notifier).toggleCompletion(_task.id);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _task.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: _task.isCompleted
                            ? AppColors.textCompleted
                            : AppColors.textPrimary,
                        decoration: _task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Priority + category chips
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _MetaChip(
                  label: _priorityLabel(),
                  color: _priorityColor(),
                  icon: Icons.flag_outlined,
                ),
                _MetaChip(
                  label: _categoryLabel(),
                  color: _categoryColor(),
                  icon: Icons.label_outline,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Due date
            if (_task.dueDate != null) ...[
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: AppStrings.dueDate,
                value: DateHelpers.full(_task.dueDate!),
                valueColor: isOverdue ? AppColors.overdueRed : null,
                trailing: isOverdue
                    ? const _Badge(
                        label: AppStrings.overdue,
                        color: AppColors.overdueRed,
                      )
                    : null,
              ),
              const SizedBox(height: 10),
            ],

            // Created timestamp
            _DetailRow(
              icon: Icons.access_time_outlined,
              label: 'Created',
              value: DateHelpers.relative(_task.createdAt),
            ),

            // Notes
            if (_task.description != null &&
                _task.description!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
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
                _task.description!,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ],

            // Subtasks section
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Subtasks',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                if (subtasks.isNotEmpty) ...[
                  const Spacer(),
                  Text(
                    '$completedSubs of ${subtasks.length} done',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            if (subtasks.isNotEmpty) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: subProgress,
                  minHeight: 6,
                  backgroundColor: AppColors.surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              ...subtasks.map(
                (sub) => _SubtaskRow(
                  subtask: sub,
                  onToggle: () => _toggleSubtask(sub),
                  onDelete: () => _deleteSubtask(sub),
                ),
              ),
            ],
            const SizedBox(height: 10),
            // Add subtask input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtaskController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Add a subtask...',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => _addSubtask(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addSubtask,
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  iconSize: 32,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubtaskRow extends StatelessWidget {
  final SubTask subtask;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _SubtaskRow({
    required this.subtask,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: subtask.isCompleted,
          activeColor: AppColors.primary,
          onChanged: (_) => onToggle(),
        ),
        Expanded(
          child: Text(
            subtask.title,
            style: TextStyle(
              fontSize: 14,
              color: subtask.isCompleted
                  ? AppColors.textCompleted
                  : AppColors.textPrimary,
              decoration:
                  subtask.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
        ),
      ],
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
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
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

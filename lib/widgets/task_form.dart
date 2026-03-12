import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';

// Bottom sheet form for creating and editing tasks
class TaskForm extends ConsumerStatefulWidget {
  final Task? existingTask;

  const TaskForm({super.key, this.existingTask});

  @override
  ConsumerState<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  late String _priority;
  late String _category;
  DateTime? _dueDate;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _priority = t?.priority ?? 'medium';
    _category = t?.category ?? 'personal';
    _dueDate = t?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isEditing) {
      final task = widget.existingTask!;
      task.title = _titleController.text.trim();
      task.description = _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim();
      task.priority = _priority;
      task.category = _category;
      task.dueDate = _dueDate;
      await ref.read(taskProvider.notifier).updateTask(task);

      // Reschedule notification if due date changed
      final notifId = task.id.hashCode;
      await NotificationService.cancel(notifId);
      if (_dueDate != null) {
        await NotificationService.scheduleForTask(
          id: notifId,
          title: task.title,
          dueDate: _dueDate!,
        );
      }
    } else {
      await ref.read(taskProvider.notifier).addTask(
            title: _titleController.text.trim(),
            description: _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
            priority: _priority,
            category: _category,
            dueDate: _dueDate,
          );

      // Schedule a notification for the new task if it has a due date
      if (_dueDate != null) {
        final tasks = ref.read(taskProvider);
        final newTask = tasks.lastWhere(
          (t) => t.title == _titleController.text.trim(),
          orElse: () => tasks.last,
        );
        await NotificationService.scheduleForTask(
          id: newTask.id.hashCode,
          title: newTask.title,
          dueDate: _dueDate!,
        );
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? AppStrings.editTask : AppStrings.addTask,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: AppStrings.titleHint,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? AppStrings.titleRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: AppStrings.descriptionHint,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _priority,
                    decoration: const InputDecoration(
                      labelText: AppStrings.priority,
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'high', child: Text(AppStrings.high)),
                      DropdownMenuItem(value: 'medium', child: Text(AppStrings.medium)),
                      DropdownMenuItem(value: 'low', child: Text(AppStrings.low)),
                    ],
                    onChanged: (v) => setState(() => _priority = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(
                      labelText: AppStrings.category,
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'work', child: Text(AppStrings.work)),
                      DropdownMenuItem(value: 'personal', child: Text(AppStrings.personal)),
                      DropdownMenuItem(value: 'shopping', child: Text(AppStrings.shopping)),
                      DropdownMenuItem(value: 'health', child: Text(AppStrings.health)),
                      DropdownMenuItem(value: 'other', child: Text(AppStrings.other)),
                    ],
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(
                _dueDate != null
                    ? DateFormat('MMM d, yyyy').format(_dueDate!)
                    : AppStrings.noDueDate,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(AppStrings.saveTask),
            ),
          ],
        ),
      ),
    );
  }
}


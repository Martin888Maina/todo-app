import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/hive_service.dart';

// Exposes the task list to the rest of the app
final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]) {
    _loadFromHive();
  }

  final _uuid = const Uuid();

  // Pull everything out of Hive on startup, sorted by the user's saved order
  void _loadFromHive() {
    final box = HiveService.taskBox;
    final tasks = box.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    state = tasks;
  }

  Future<void> addTask({
    required String title,
    String? description,
    String priority = 'medium',
    String category = 'personal',
    DateTime? dueDate,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      category: category,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      sortOrder: state.length,
    );

    await HiveService.taskBox.put(task.id, task);
    state = [...state, task];
  }

  Future<void> updateTask(Task task) async {
    await task.save();
    // Replace the old entry in state so the UI rebuilds
    state = state.map((t) => t.id == task.id ? task : t).toList();
  }

  Future<void> deleteTask(String id) async {
    await HiveService.taskBox.delete(id);
    state = state.where((t) => t.id != id).toList();
  }

  Future<void> toggleCompletion(String id) async {
    final task = state.firstWhere((t) => t.id == id);
    task.isCompleted = !task.isCompleted;
    await task.save();
    state = [...state];
  }

  // Restores a task that was just deleted — used by the undo snackbar
  Future<void> restoreTask(Task task) async {
    await HiveService.taskBox.put(task.id, task);
    final updated = [...state, task]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    state = updated;
  }
}

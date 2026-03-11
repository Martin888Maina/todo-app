import 'package:hive/hive.dart';

part 'task.g.dart';

// Represents a single subtask item within a parent task
@HiveType(typeId: 1)
class SubTask extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

// Main task model — all fields map directly to what the user sees in the app
@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  String priority; // "high", "medium", "low"

  @HiveField(5)
  String category; // "work", "personal", "shopping", "health", "other"

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? dueDate;

  @HiveField(8)
  int sortOrder;

  @HiveField(9)
  List<SubTask>? subtasks;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = 'medium',
    this.category = 'personal',
    required this.createdAt,
    this.dueDate,
    this.sortOrder = 0,
    this.subtasks,
  });
}

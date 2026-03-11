import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

// Centralises Hive setup so main.dart stays clean
class HiveService {
  static const String taskBoxName = 'tasks';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters before opening any boxes
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SubTaskAdapter());
    }

    await Hive.openBox<Task>(taskBoxName);
  }

  static Box<Task> get taskBox => Hive.box<Task>(taskBoxName);
}

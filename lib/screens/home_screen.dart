import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/filter_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../widgets/task_form.dart';
import '../widgets/task_tile.dart';
import '../widgets/filter_tabs.dart';
import '../widgets/category_chip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _searchVisible = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openForm({Task? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => TaskForm(existingTask: task),
    );
  }

  void _deleteTask(Task task) {
    ref.read(taskProvider.notifier).deleteTask(task.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.taskDeleted),
        action: SnackBarAction(
          label: AppStrings.undo,
          onPressed: () => ref.read(taskProvider.notifier).restoreTask(task),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // Applies status, search, and category filters together
  List<Task> _filteredTasks(List<Task> all) {
    final status = ref.watch(statusFilterProvider);
    final query = ref.watch(searchQueryProvider).toLowerCase().trim();
    final category = ref.watch(categoryFilterProvider);

    return all.where((t) {
      // Status filter
      if (status == 'active' && t.isCompleted) return false;
      if (status == 'completed' && !t.isCompleted) return false;

      // Category filter
      if (category != null && t.category != category) return false;

      // Search filter — checks title and description
      if (query.isNotEmpty) {
        final inTitle = t.title.toLowerCase().contains(query);
        final inDesc = t.description?.toLowerCase().contains(query) ?? false;
        if (!inTitle && !inDesc) return false;
      }

      return true;
    }).toList();
  }

  String _taskCounterText(List<Task> all) {
    final activeCount = all.where((t) => !t.isCompleted).length;
    if (activeCount == 0) return AppStrings.allDone;
    if (activeCount == 1) return '1 ${AppStrings.taskLeft}';
    return '$activeCount ${AppStrings.tasksLeft}';
  }

  String _emptyMessage() {
    final status = ref.read(statusFilterProvider);
    final query = ref.read(searchQueryProvider);
    if (query.isNotEmpty) return AppStrings.emptySearch;
    if (status == 'active') return AppStrings.emptyActive;
    if (status == 'completed') return AppStrings.emptyCompleted;
    return AppStrings.emptyAll;
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskProvider);
    final visible = _filteredTasks(allTasks);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: _searchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: AppStrings.searchHint,
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (v) =>
                    ref.read(searchQueryProvider.notifier).state = v,
              )
            : const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: Icon(_searchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _searchVisible = !_searchVisible);
              if (!_searchVisible) {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter tabs
          Container(
            color: AppColors.background,
            child: const FilterTabs(),
          ),
          // Category chips
          const CategoryChipRow(),
          // Task counter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text(
              _taskCounterText(allTasks),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Divider(height: 1),
          // Task list
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Text(
                      _emptyMessage(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final task = visible[index];
                      return TaskTile(
                        task: task,
                        onToggle: () => ref
                            .read(taskProvider.notifier)
                            .toggleCompletion(task.id),
                        onTap: () => _openForm(task: task),
                        onDelete: () => _deleteTask(task),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
import '../widgets/empty_state.dart';
import 'task_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _searchVisible = false;
  bool _sortByPriority = false;
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

  void _openDetail(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
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

  Future<void> _confirmClearCompleted() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.clearCompletedConfirm),
        content: const Text(AppStrings.clearCompletedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.priorityHigh),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(taskProvider.notifier).clearCompleted();
    }
  }

  // Priority sort order: high=0, medium=1, low=2
  int _priorityOrder(String p) {
    if (p == 'high') return 0;
    if (p == 'medium') return 1;
    return 2;
  }

  List<Task> _filteredTasks(List<Task> all) {
    final status = ref.watch(statusFilterProvider);
    final query = ref.watch(searchQueryProvider).toLowerCase().trim();
    final category = ref.watch(categoryFilterProvider);

    var result = all.where((t) {
      if (status == 'active' && t.isCompleted) return false;
      if (status == 'completed' && !t.isCompleted) return false;
      if (category != null && t.category != category) return false;
      if (query.isNotEmpty) {
        final inTitle = t.title.toLowerCase().contains(query);
        final inDesc = t.description?.toLowerCase().contains(query) ?? false;
        if (!inTitle && !inDesc) return false;
      }
      return true;
    }).toList();

    if (_sortByPriority) {
      result.sort((a, b) =>
          _priorityOrder(a.priority).compareTo(_priorityOrder(b.priority)));
    }

    return result;
  }

  String _taskCounterText(List<Task> all) {
    final activeCount = all.where((t) => !t.isCompleted).length;
    if (activeCount == 0) return AppStrings.allDone;
    if (activeCount == 1) return '1 ${AppStrings.taskLeft}';
    return '$activeCount ${AppStrings.tasksLeft}';
  }

  EmptyState _emptyState() {
    final status = ref.read(statusFilterProvider);
    final query = ref.read(searchQueryProvider);

    if (query.isNotEmpty) {
      return const EmptyState(
        message: AppStrings.emptySearch,
        icon: Icons.search_off_rounded,
      );
    }
    if (status == 'active') {
      return const EmptyState(
        message: AppStrings.emptyActive,
        icon: Icons.task_alt_rounded,
      );
    }
    if (status == 'completed') {
      return const EmptyState(
        message: AppStrings.emptyCompleted,
        icon: Icons.hourglass_empty_rounded,
      );
    }
    return const EmptyState(
      message: AppStrings.emptyAll,
      icon: Icons.checklist_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskProvider);
    final visible = _filteredTasks(allTasks);
    final isFiltered = ref.watch(statusFilterProvider) != 'all' ||
        ref.watch(searchQueryProvider).isNotEmpty ||
        ref.watch(categoryFilterProvider) != null ||
        _sortByPriority;

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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle_all') {
                ref.read(taskProvider.notifier).toggleAll();
              } else if (value == 'clear_completed') {
                _confirmClearCompleted();
              } else if (value == 'sort_priority') {
                setState(() => _sortByPriority = !_sortByPriority);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'sort_priority',
                child: Text(
                  _sortByPriority ? 'Sort: Default order' : 'Sort: By priority',
                ),
              ),
              const PopupMenuItem(
                value: 'toggle_all',
                child: Text(AppStrings.toggleAll),
              ),
              const PopupMenuItem(
                value: 'clear_completed',
                child: Text(AppStrings.clearCompleted),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.background,
            child: const FilterTabs(),
          ),
          const CategoryChipRow(),
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
          Expanded(
            child: visible.isEmpty
                ? _emptyState()
                : isFiltered
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final task = visible[index];
                          return TaskTile(
                            key: Key(task.id),
                            task: task,
                            onToggle: () => ref
                                .read(taskProvider.notifier)
                                .toggleCompletion(task.id),
                            onTap: () => _openDetail(task),
                            onDelete: () => _deleteTask(task),
                          );
                        },
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: visible.length,
                        onReorder: (oldIndex, newIndex) {
                          ref
                              .read(taskProvider.notifier)
                              .reorderTasks(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final task = visible[index];
                          return TaskTile(
                            key: Key(task.id),
                            task: task,
                            onToggle: () => ref
                                .read(taskProvider.notifier)
                                .toggleCompletion(task.id),
                            onTap: () => _openDetail(task),
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

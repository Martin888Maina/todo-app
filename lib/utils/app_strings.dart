// All user-facing strings in one place — avoids hardcoded text scattered across widgets
class AppStrings {
  AppStrings._();

  static const String appName = 'Todo App';
  static const String addTask = 'Add Task';
  static const String editTask = 'Edit Task';
  static const String deleteTask = 'Delete Task';
  static const String saveTask = 'Save';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';

  // Task fields
  static const String titleHint = 'Task title';
  static const String descriptionHint = 'Notes (optional)';
  static const String priority = 'Priority';
  static const String category = 'Category';
  static const String dueDate = 'Due date';
  static const String noDueDate = 'No due date';
  static const String overdue = 'Overdue';

  // Priority labels
  static const String high = 'High';
  static const String medium = 'Medium';
  static const String low = 'Low';

  // Category labels
  static const String work = 'Work';
  static const String personal = 'Personal';
  static const String shopping = 'Shopping';
  static const String health = 'Health';
  static const String other = 'Other';

  // Filter tabs
  static const String all = 'All';
  static const String active = 'Active';
  static const String completed = 'Completed';

  // Task counter
  static const String taskLeft = 'task left';
  static const String tasksLeft = 'tasks left';
  static const String allDone = 'All done!';

  // Empty states
  static const String emptyAll = 'No tasks yet. Tap + to add one!';
  static const String emptyActive = 'All tasks completed!';
  static const String emptyCompleted = 'No completed tasks yet';
  static const String emptySearch = 'No tasks match your search';

  // Bulk actions
  static const String clearCompleted = 'Clear completed';
  static const String toggleAll = 'Toggle all';
  static const String clearCompletedConfirm = 'Clear all completed tasks?';
  static const String clearCompletedMessage =
      'This will permanently remove all completed tasks.';

  // Undo
  static const String taskDeleted = 'Task deleted';
  static const String undo = 'Undo';

  // Search
  static const String searchHint = 'Search tasks...';

  // Statistics
  static const String statistics = 'Statistics';
  static const String totalTasks = 'Total tasks';
  static const String completedTasks = 'Completed';
  static const String pendingTasks = 'Pending';
  static const String completionRate = 'Completion rate';
  static const String byCategory = 'By category';
  static const String byPriority = 'By priority';

  // Notifications
  static const String notificationChannelId = 'todo_due_dates';
  static const String notificationChannelName = 'Task Due Dates';
  static const String notificationChannelDesc =
      'Reminders for tasks with due dates';
  static const String notificationTitle = 'Task due today';

  // Onboarding
  static const String onboardingSkip = 'Skip';
  static const String onboardingNext = 'Next';
  static const String onboardingGetStarted = 'Get Started';
  static const String onboarding1Title = 'Stay Organised';
  static const String onboarding1Body =
      'Create tasks, set priorities, and track your progress all in one place.';
  static const String onboarding2Title = 'Swipe to Manage';
  static const String onboarding2Body =
      'Swipe left to delete a task. Swipe right to mark it complete.';
  static const String onboarding3Title = 'Reorder with Ease';
  static const String onboarding3Body =
      'Long-press any task and drag it to reorder your list exactly the way you want.';

  // Theme
  static const String lightMode = 'Light mode';
  static const String darkMode = 'Dark mode';
}

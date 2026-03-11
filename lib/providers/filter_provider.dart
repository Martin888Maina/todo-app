import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tracks which status tab the user has selected
final statusFilterProvider = StateProvider<String>((ref) => 'all');

// Tracks the current search query typed in the search bar
final searchQueryProvider = StateProvider<String>((ref) => '');

// Tracks the selected category chip — null means "show all categories"
final categoryFilterProvider = StateProvider<String?>((ref) => null);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';

// Horizontal scrolling row of category filter chips
class CategoryChipRow extends ConsumerWidget {
  const CategoryChipRow({super.key});

  static const _categories = [
    ('work', AppStrings.work, AppColors.categoryWork),
    ('personal', AppStrings.personal, AppColors.categoryPersonal),
    ('shopping', AppStrings.shopping, AppColors.categoryShopping),
    ('health', AppStrings.health, AppColors.categoryHealth),
    ('other', AppStrings.other, AppColors.categoryOther),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(categoryFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          // "All" chip resets the category filter
          _buildChip(
            label: AppStrings.all,
            color: AppColors.primary,
            isSelected: selected == null,
            onTap: () => ref.read(categoryFilterProvider.notifier).state = null,
          ),
          const SizedBox(width: 8),
          ..._categories.map((entry) {
            final (value, label, color) = entry;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                label: label,
                color: color,
                isSelected: selected == value,
                onTap: () {
                  // Tapping the active chip deselects it
                  final notifier = ref.read(categoryFilterProvider.notifier);
                  notifier.state = selected == value ? null : value;
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

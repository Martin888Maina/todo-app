import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';

// The All / Active / Completed tab bar
class FilterTabs extends ConsumerWidget {
  const FilterTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(statusFilterProvider);

    return Row(
      children: [
        _Tab(label: AppStrings.all, value: 'all', current: current, ref: ref),
        _Tab(label: AppStrings.active, value: 'active', current: current, ref: ref),
        _Tab(label: AppStrings.completed, value: 'completed', current: current, ref: ref),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final WidgetRef ref;

  const _Tab({
    required this.label,
    required this.value,
    required this.current,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = current == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(statusFilterProvider.notifier).state = value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

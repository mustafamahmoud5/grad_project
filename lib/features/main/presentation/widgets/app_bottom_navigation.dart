import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.search_rounded, 'Search'),
    (Icons.explore_rounded, 'Browse'),
    (Icons.account_circle_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          height: 62,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _items.length; i++)
                IconButton(
                  tooltip: _items[i].$2,
                  isSelected: i == selectedIndex,
                  onPressed: () => onSelected(i),
                  icon: Icon(
                    _items[i].$1,
                    size: 30,
                    color: i == selectedIndex
                        ? AppColors.primary
                        : AppColors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

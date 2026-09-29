import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/asset_constants.dart';

class AvatarCarousel extends StatefulWidget {
  const AvatarCarousel({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  State<AvatarCarousel> createState() => _AvatarCarouselState();
}

class _AvatarCarouselState extends State<AvatarCarousel> {
  late final _controller = PageController(
    viewportFraction: 0.38,
    initialPage: widget.selectedIndex,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 160,
    child: PageView.builder(
      controller: _controller,
      itemCount: AssetConstants.avatars.length,
      onPageChanged: widget.onChanged,
      itemBuilder: (context, index) {
        final selected = index == widget.selectedIndex;
        return GestureDetector(
          onTap: () => _controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
          child: AnimatedScale(
            scale: selected ? 1 : 0.65,
            duration: const Duration(milliseconds: 250),
            child: Semantics(
              selected: selected,
              label: 'Avatar ${index + 1}',
              child: Image.asset(
                AssetConstants.avatars[index],
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    ),
  );
}

Future<int?> showAvatarPicker(BuildContext context, int selectedIndex) =>
    showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: AssetConstants.avatars.length,
          itemBuilder: (context, index) {
            final selected = index == selectedIndex;
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).pop(index),
              child: Ink(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.6)
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Image.asset(AssetConstants.avatars[index]),
              ),
            );
          },
        ),
      ),
    );

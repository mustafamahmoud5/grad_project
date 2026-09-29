import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  final String backgroundImage;
  final String frameImage;
  final String title;
  final String description;
  final String buttonText;
  final bool showBack;
  final int currentPage;
  final int pageCount;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const OnboardingPage({
    super.key,
    required this.backgroundImage,
    required this.frameImage,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.showBack,
    required this.currentPage,
    required this.pageCount,
    required this.onNext,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(backgroundImage, fit: BoxFit.cover),

        Image.asset(frameImage, fit: BoxFit.cover),

        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Color(0x22000000),
                AppColors.background,
              ],
              stops: [0.0, 0.45, 0.70, 1.0],
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(16, size.height * 0.028, 16, 18),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: size.width < 380 ? 22 : 24,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),

                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 14),

                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontSize: size.width < 380 ? 16 : 17,
                          height: 1.35,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    _PageIndicator(
                      currentPage: currentPage,
                      pageCount: pageCount,
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    if (showBack) ...[
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: onBack,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const _PageIndicator({required this.currentPage, required this.pageCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

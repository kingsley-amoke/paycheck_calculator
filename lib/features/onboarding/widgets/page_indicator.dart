import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int total;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: isActive ? AppColors.primary : AppColors.outlineVariant,
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class HookIllustration extends StatelessWidget {
  const HookIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.72;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
            ),
          ),
          // Inner ring with shadow
          Container(
            width: size * 0.5,
            height: size * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerLowest,
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withValues(alpha: 0.05),
                  blurRadius: 60,
                  offset: const Offset(0, 40),
                ),
              ],
            ),
          ),
          // Central image card
          Padding(
            padding: EdgeInsets.all(size * 0.1),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/hook.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.surfaceContainerLow,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppColors.outlineVariant,
                        size: 48,
                      ),
                    ),
                  ),
                  // Gradient overlay for depth
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.transparent,
                          AppColors.primary.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Currency exchange badge (top-right overlay)
          Positioned(
            top: size * 0.14,
            right: size * 0.06,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.currency_exchange,
                color: AppColors.secondary,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

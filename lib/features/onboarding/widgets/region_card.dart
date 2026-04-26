import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

// Badge specification (position + icon)
class BadgeSpec {
  final IconData icon;
  final Color color;
  final double? top, bottom, left, right;

  const BadgeSpec({
    required this.icon,
    required this.color,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });
}

class RegionCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color sublabelColor;
  final Color iconBg;
  final Color iconColor;
  final double scale;
  final Color borderColor;
  final List<BadgeSpec> badges;

  const RegionCard({
    super.key,
    required this.label,
    required this.sublabel,
    required this.sublabelColor,
    required this.iconBg,
    required this.iconColor,
    required this.scale,
    required this.borderColor,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    final cardSize = 110.0 * scale + (scale == 1.0 ? 30 : 0);

    return SizedBox(
      width: cardSize + 24,
      height: cardSize + 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Card body
          Container(
            width: cardSize,
            height: cardSize,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: borderColor == Colors.transparent
                  ? null
                  : Border.all(
                      color: borderColor.withOpacity(0.35),
                      width: 1.5,
                    ),
              boxShadow: [
                BoxShadow(
                  color: scale == 1.0
                      ? AppColors.primary.withOpacity(0.08)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: scale == 1.0 ? 40 : 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon circle
                Container(
                  width: scale == 1.0 ? 56 : 44,
                  height: scale == 1.0 ? 56 : 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBg,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: iconColor,
                    size: scale == 1.0 ? 30 : 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: scale == 1.0 ? 22 : 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sublabel.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: sublabelColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Floating badges
          for (final b in badges)
            Positioned(
              top: b.top,
              bottom: b.bottom,
              left: b.left,
              right: b.right,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(b.icon, color: b.color, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}

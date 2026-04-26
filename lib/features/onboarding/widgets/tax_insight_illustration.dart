import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class TaxInsightIllustration extends StatelessWidget {
  final List<Animation<double>> barHeights;
  final List<(double, double)> bars;
  final Animation<Offset> floatOffset;
  final Animation<double> floatScale;
  final Animation<double> pulseOpacity;
  final Animation<double> pulseScale;

  const TaxInsightIllustration({
    super.key,
    required this.barHeights,
    required this.bars,
    required this.floatOffset,
    required this.floatScale,
    required this.pulseOpacity,
    required this.pulseScale,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing rotated background shape
          AnimatedBuilder(
            animation: pulseOpacity,
            builder: (_, _) => Opacity(
              opacity: pulseOpacity.value,
              child: Transform.scale(
                scale: pulseScale.value,
                child: Transform.rotate(
                  angle: 0.052, // ~3 degrees
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(48),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main card
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(48),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.1),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 60,
                  offset: Offset(0, 40),
                  spreadRadius: -15,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Network image overlay (10% opacity, blend)
                ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: Opacity(
                    opacity: 0.10,
                    child: Image.asset(
                      '/assets/images/search.pmg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),

                // Inner content: chart + skeleton lines
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      // Chart area
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh.withValues(
                              alpha: 0.30,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            children: [
                              // Bar chart
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: List.generate(bars.length, (i) {
                                    final (heightFrac, opacFrac) = bars[i];
                                    final isTallest = opacFrac == 1.0;
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: AnimatedBuilder(
                                          animation: barHeights[i],
                                          builder: (_, _) {
                                            return FractionallySizedBox(
                                              heightFactor:
                                                  heightFrac *
                                                  barHeights[i].value,
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withValues(
                                                        alpha: opacFrac,
                                                      ),
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                        top: Radius.circular(6),
                                                      ),
                                                  boxShadow: isTallest
                                                      ? [
                                                          BoxShadow(
                                                            color: AppColors
                                                                .primary
                                                                .withValues(
                                                                  alpha: 0.2,
                                                                ),
                                                            blurRadius: 12,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  4,
                                                                ),
                                                          ),
                                                        ]
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Skeleton lines
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonLine(widthFrac: 0.75),
                          const SizedBox(height: 10),
                          _SkeletonLine(widthFrac: 0.50),
                        ],
                      ),
                    ],
                  ),
                ),

                // Floating magnifier badge (centred)
                Center(
                  child: SlideTransition(
                    position: floatOffset,
                    child: ScaleTransition(
                      scale: floatScale,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF3525CD), Color(0xFF4F46E5)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.surfaceContainerLowest,
                            width: 5,
                          ),
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double widthFrac;

  const _SkeletonLine({required this.widthFrac});

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: widthFrac,
    child: Container(
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
      ),
    ),
  );
}

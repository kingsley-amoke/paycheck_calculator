import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/fade_up_animation.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/pop_in_animation.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/region_card.dart';

import '../../../core/constants/app_colors.dart';

class ComparisonIllustration extends StatefulWidget {
  const ComparisonIllustration({super.key});

  @override
  State<ComparisonIllustration> createState() => _ComparisonIllustrationState();
}

class _ComparisonIllustrationState extends State<ComparisonIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _stagger;

  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;
  late final List<Animation<double>> _scales;

  @override
  void initState() {
    super.initState();

    // ── Stagger (800 ms total) ───────────────────────────────────────────
    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    const delays = [0.08, 0.25, 0.42, 0.58];
    const end = 0.90;

    _fades = delays
        .map(
          (s) => Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: _stagger,
              curve: Interval(s, end, curve: Curves.easeOut),
            ),
          ),
        )
        .toList();

    _slides = delays
        .map(
          (s) => Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _stagger,
                  curve: Interval(s, end, curve: Curves.easeOut),
                ),
              ),
        )
        .toList();

    // Pop-in scale for cards (elastic overshoot)
    _scales = delays
        .map(
          (s) => Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: _stagger,
              curve: Interval(s, end, curve: const ElasticOutCurve(0.7)),
            ),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _stagger.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Blurry background blob
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Region A — CA (smaller, high-tax)
              PopInAnimation(
                scales: _scales,
                fades: _fades,
                index: 0,
                child: RegionCard(
                  label: 'CA',
                  sublabel: 'High Tax',
                  sublabelColor: AppColors.error,
                  iconBg: AppColors.errorContainer,
                  iconColor: AppColors.error,
                  scale: 0.9,
                  borderColor: Colors.transparent,
                  badges: [
                    BadgeSpec(
                      icon: Icons.monetization_on,
                      color: AppColors.primary,
                      top: -14,
                      right: -14,
                    ),
                  ],
                ),
              ),

              // VS divider
              FadeUpAnimation(
                slides: _slides,
                fades: _fades,
                index: 1,
                child: Container(
                  width: 1,
                  height: 96,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),

              // Region B — TX (larger, zero-tax) — hero card
              PopInAnimation(
                scales: _scales,
                fades: _fades,
                index: 2,
                child: const RegionCard(
                  label: 'TX',
                  sublabel: 'Zero Tax',
                  sublabelColor: AppColors.secondary,
                  iconBg: AppColors.secondaryContainer,
                  iconColor: AppColors.secondary,
                  scale: 1.0,
                  borderColor: AppColors.secondaryContainer,
                  badges: [
                    BadgeSpec(
                      icon: Icons.add_circle,
                      color: AppColors.secondary,
                      top: -18,
                      left: -8,
                    ),
                    BadgeSpec(
                      icon: Icons.trending_up,
                      color: AppColors.secondary,
                      bottom: -14,
                      right: -8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

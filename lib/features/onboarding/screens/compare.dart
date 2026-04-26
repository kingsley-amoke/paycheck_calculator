import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/onboarding/screens/insights.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/comparison_illustration.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/cta_button.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/fade_up_animation.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/subtitle_text.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/title_text.dart';

import '../../../core/constants/app_colors.dart';
import '../widgets/page_indicator.dart';

class CompareSaveScreen extends StatefulWidget {
  const CompareSaveScreen({super.key});

  @override
  State<CompareSaveScreen> createState() => _CompareSaveScreenState();
}

class _CompareSaveScreenState extends State<CompareSaveScreen>
    with TickerProviderStateMixin {
  late final AnimationController _stagger;

  late final AnimationController _arrowNudge;

  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();

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

    // ── Arrow nudge loop ─────────────────────────────────────────────────
    _arrowNudge = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _stagger.dispose();
    _arrowNudge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ── Green radial glow (top-right) ──────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.4, -0.4),
                    radius: 1.0,
                    colors: [
                      AppColors.secondaryContainer.withValues(alpha: 0.18),
                      AppColors.surface.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Layout ────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ComparisonIllustration(),
                      const SizedBox(height: 32),
                      TitleText(text: 'Compare & Save'),
                      SizedBox(height: 16),
                      FadeUpAnimation(
                        slides: _slides,
                        fades: _fades,
                        index: 3,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: SubtitleText(
                            text:
                                'Planning a move? Compare tax rates between different states and regions to see where your salary goes further.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                FadeUpAnimation(
                  fades: _fades,
                  slides: _slides,
                  index: 1,
                  child: const PageIndicator(currentPage: 1, total: 3),
                ),
                const SizedBox(height: 24),
                FadeUpAnimation(
                  fades: _fades,
                  slides: _slides,
                  index: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: CTAButton(
                      pulseController: _stagger,
                      text: 'Next',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TaxInsightsScreen(),
                          ),
                        );
                      },
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

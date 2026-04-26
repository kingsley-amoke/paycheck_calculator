import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/onboarding/screens/compare.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/cta_button.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/fade_up_animation.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/hook_illustration.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/title_text.dart';
import 'package:paycheck_calculator/features/paywall/paywall_screen_2.dart';

import '../widgets/glow_orb.dart';
import '../widgets/page_indicator.dart';
import '../widgets/subtitle_text.dart';

// ── Colour tokens (mirrors your Tailwind config) ────────────────────────────
class AppColors {
  static const primary = Color(0xFF3525CD);
  static const primaryContainer = Color(0xFF4F46E5);
  static const secondary = Color(0xFF006E2D);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceContainerLow = Color(0xFFF3F4F5);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF464555);
  static const outlineVariant = Color(0xFFC7C4D8);
  static const onPrimaryFixedVariant = Color(0xFF3323CC);
}

// ── Main onboarding screen ───────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;

  // Staggered fade-up animations
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();

    // Pulse for the CTA button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Stagger controller drives all fade-up reveals
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    // 5 staggered steps at 100 ms, 300 ms, 500 ms, 700 ms, 900 ms
    const delays = [0.0, 0.10, 0.28, 0.45, 0.60];
    const endPct = 0.85;

    _fadeAnims = delays.map((start) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, endPct, curve: Curves.easeOut),
        ),
      );
    }).toList();

    _slideAnims = delays.map((start) {
      return Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, endPct, curve: Curves.easeOut),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ── Background glow ornaments ───────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).size.height * 0.22,
            right: -64,
            child: GlowOrb(
              size: 256,
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.22,
            left: -64,
            child: GlowOrb(
              size: 192,
              color: AppColors.secondary.withValues(alpha: 0.05),
            ),
          ),

          // ── Radial soft glow behind content ────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.6),
                  radius: 1.2,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.surface.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // ── Main layout ─────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Hero illustration
                        FadeUpAnimation(
                          index: 1,
                          slides: _slideAnims,
                          fades: _fadeAnims,
                          child: const HookIllustration(),
                        ),

                        const SizedBox(height: 24),

                        // Heading
                        FadeUpAnimation(
                          slides: _slideAnims,
                          fades: _fadeAnims,
                          index: 2,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: TitleText(
                              text: 'Know Your ',
                              styledText: 'Real Worth',
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Subtitle
                        FadeUpAnimation(
                          slides: _slideAnims,
                          fades: _fadeAnims,
                          index: 3,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: SubtitleText(
                              text:
                                  'Calculate your take-home pay instantly after federal, state, and local taxes across 50+ countries.',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                FadeUpAnimation(
                  slides: _slideAnims,
                  fades: _fadeAnims,
                  index: 4,
                  child: const PageIndicator(currentPage: 0, total: 3),
                ),
                const SizedBox(height: 32),
                FadeUpAnimation(
                  fades: _fadeAnims,
                  slides: _slideAnims,
                  index: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: CTAButton(
                      pulseController: _pulseController,
                      text: 'Next',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CompareSaveScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

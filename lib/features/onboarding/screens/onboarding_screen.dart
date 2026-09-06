import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/constants/app_colors.dart';
import 'package:paycheck_calculator/features/onboarding/screens/generating_page.dart';
import 'package:paycheck_calculator/features/onboarding/screens/goals_page.dart';
import 'package:paycheck_calculator/features/onboarding/screens/hook.dart';
import 'package:paycheck_calculator/features/onboarding/screens/location_page.dart';
import 'package:paycheck_calculator/features/onboarding/screens/salary_page.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/cta_button.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/fade_up_animation.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/glow_orb.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();

  int currentPage = 0;

  // ── ANIMATIONS ───────────────────────────────────────────────────────────

  late final AnimationController _pulseController;
  late final AnimationController _staggerController;

  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

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
    _pageController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────

  void nextPage() {
    if (currentPage == 4) {
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void previousPage() {
    if (currentPage == 0) {
      return;
    }

    _pageController.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ── BACKGROUND GLOWS ────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            right: -80,
            child: GlowOrb(
              size: 260,
              color: AppColors.primary.withValues(alpha: 0.06),
            ),
          ),

          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.18,
            left: -70,
            child: GlowOrb(
              size: 220,
              color: AppColors.secondary.withValues(alpha: 0.05),
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.5),
                  radius: 1.2,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.surface.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // ── CONTENT ────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── TOP BAR ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // ── BACK BUTTON ──────────────────
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: currentPage == 0 ? 0 : 1,
                        child: IgnorePointer(
                          ignoring: currentPage == 0,
                          child: GestureDetector(
                            onTap: previousPage,
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.04),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // ── SKIP BUTTON ──────────────────
                      if (currentPage < 3)
                        GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              3,
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,

                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (value) {
                      setState(() {
                        currentPage = value;
                      });

                      _staggerController.forward(from: 0);
                    },
                    children: [
                      Hook(fadeAnims: _fadeAnims, slideAnims: _slideAnims),
                      LocationPage(
                        fadeAnims: _fadeAnims,
                        slideAnims: _slideAnims,
                      ),
                      SalaryPage(
                        fadeAnims: _fadeAnims,
                        slideAnims: _slideAnims,
                      ),
                      GoalsPage(fadeAnims: _fadeAnims, slideAnims: _slideAnims),
                      GeneratingPage(),
                    ],
                  ),
                ),

                FadeUpAnimation(
                  fades: _fadeAnims,
                  slides: _slideAnims,
                  index: 4,
                  child: PageIndicator(currentPage: currentPage, total: 5),
                ),

                const SizedBox(height: 8),

                if (currentPage != 4)
                  FadeUpAnimation(
                    fades: _fadeAnims,
                    slides: _slideAnims,
                    index: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: CTAButton(
                        pulseController: _pulseController,
                        text: currentPage == 3
                            ? 'Generate My Report'
                            : 'Continue',
                        onTap: nextPage,
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

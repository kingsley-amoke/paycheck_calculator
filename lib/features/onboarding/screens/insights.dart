import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/cta_button.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/page_indicator.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/subtitle_text.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/tax_insight_illustration.dart';
import 'package:paycheck_calculator/features/paywall/purchase_view.dart';

import '../../../core/constants/app_colors.dart';
import '../widgets/fade_up_animation.dart';
import '../widgets/title_text.dart';

class TaxInsightsScreen extends StatefulWidget {
  const TaxInsightsScreen({super.key});

  @override
  State<TaxInsightsScreen> createState() => _TaxInsightsScreenState();
}

class _TaxInsightsScreenState extends State<TaxInsightsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _stagger;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  late final AnimationController _barGrow;
  late final List<Animation<double>> _barHeights;

  late final AnimationController _float;
  late final Animation<Offset> _floatOffset;
  late final Animation<double> _floatScale;

  late final AnimationController _pulse;
  late final Animation<double> _pulseOpacity;
  late final Animation<double> _pulseScale;

  static const _bars = [
    (0.50, 0.10),
    (0.75, 0.20),
    (1.00, 1.00), // tallest, full primary
    (0.66, 0.40),
    (0.33, 0.10),
  ];

  @override
  void initState() {
    super.initState();

    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    // Delays matching HTML: 200, 300, 500, 600, 700, 800, 1000 ms
    // Mapped to 7 stagger slots
    const delays = [0.14, 0.21, 0.36, 0.43, 0.50, 0.57, 0.71];
    const endT = 0.95;

    _fades = delays
        .map(
          (s) => Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: _stagger,
              curve: Interval(s, endT, curve: Curves.easeOut),
            ),
          ),
        )
        .toList();

    _slides = delays
        .map(
          (s) => Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _stagger,
                  curve: Interval(s, endT, curve: Curves.easeOut),
                ),
              ),
        )
        .toList();

    _barGrow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    // Each bar gets a staggered interval
    final barDelays = [0.21, 0.29, 0.36, 0.43, 0.50];
    _barHeights = barDelays
        .map(
          (s) => Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: _barGrow,
              curve: Interval(s, 0.95, curve: const ElasticOutCurve(0.75)),
            ),
          ),
        )
        .toList();

    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _floatOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.12),
    ).animate(CurvedAnimation(parent: _float, curve: Curves.easeInOut));

    _floatScale = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _float, curve: Curves.easeInOut));

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _pulseOpacity = Tween<double>(
      begin: 0.4,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

    _pulseScale = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _stagger.dispose();
    _barGrow.dispose();
    _float.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.6, -0.5),
                    radius: 1.0,
                    colors: [
                      AppColors.primaryContainer.withValues(alpha: 0.08),
                      AppColors.surface.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Bento illustration card
                        FadeUpAnimation(
                          slides: _slides,
                          fades: _fades,
                          index: 1,
                          child: TaxInsightIllustration(
                            barHeights: _barHeights,
                            bars: _bars,
                            floatOffset: _floatOffset,
                            floatScale: _floatScale,
                            pulseOpacity: _pulseOpacity,
                            pulseScale: _pulseScale,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Heading
                        FadeUpAnimation(
                          slides: _slides,
                          fades: _fades,
                          index: 3,
                          child: TitleText(
                            text: 'Smart Tax ',
                            styledText: 'Insights',
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Subtitle
                        FadeUpAnimation(
                          slides: _slides,
                          fades: _fades,
                          index: 4,
                          child: const SubtitleText(
                            text:
                                'Get deep-dive breakdowns and personalized insights into your effective tax rate and how to optimize it.',
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                FadeUpAnimation(
                  slides: _slides,
                  fades: _fades,
                  index: 5,
                  child: PageIndicator(currentPage: 2, total: 3),
                ),

                const SizedBox(height: 32),

                // CTA button
                FadeUpAnimation(
                  slides: _slides,
                  fades: _fades,
                  index: 6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: CTAButton(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PurchaseView()),
                        );
                      },
                      pulseController: _stagger,
                      text: 'Get Started',
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

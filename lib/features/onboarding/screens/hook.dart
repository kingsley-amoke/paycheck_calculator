import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/constants/app_colors.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/fade_up_animation.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/hook_illustration.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/title_text.dart';

import '../widgets/subtitle_text.dart';

class Hook extends StatelessWidget {
  const Hook({super.key, required this.fadeAnims, required this.slideAnims});

  final List<Animation<double>> fadeAnims;
  final List<Animation<Offset>> slideAnims;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeUpAnimation(
            fades: fadeAnims,
            slides: slideAnims,
            index: 1,
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.03),
                  ],
                ),
              ),
              child: HookIllustration(),
            ),
          ),

          const SizedBox(height: 40),

          FadeUpAnimation(
            fades: fadeAnims,
            slides: slideAnims,
            index: 2,
            child: const TitleText(
              text: 'Let’s Calculate Your ',
              styledText: 'Real Paycheck',
            ),
          ),

          const SizedBox(height: 16),

          FadeUpAnimation(
            fades: fadeAnims,
            slides: slideAnims,
            index: 3,
            child: const SubtitleText(
              text:
                  'Answer a few quick questions to generate your personalized take-home pay estimate.',
            ),
          ),
        ],
      ),
    );
  }
}

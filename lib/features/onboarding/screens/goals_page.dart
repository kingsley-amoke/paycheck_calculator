import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/constants/app_colors.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/fade_up_animation.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/title_text.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({
    super.key,
    required this.fadeAnims,
    required this.slideAnims,
  });

  final List<Animation<double>> fadeAnims;
  final List<Animation<Offset>> slideAnims;

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final List<String> goals = [
    'Better budgeting',
    'Tax optimization',
    'Overtime calculations',
    'Net salary accuracy',
  ];

  final List<String> selectedGoals = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeUpAnimation(
            fades: widget.fadeAnims,
            slides: widget.slideAnims,
            index: 1,
            child: const Icon(
              Icons.auto_graph_rounded,
              size: 100,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 32),

          FadeUpAnimation(
            fades: widget.fadeAnims,
            slides: widget.slideAnims,
            index: 2,
            child: const TitleText(
              text: 'What Would You Like ',
              styledText: 'Help With?',
            ),
          ),

          const SizedBox(height: 40),

          ...goals.map(_goalTile),
        ],
      ),
    );
  }

  Widget _goalTile(String goal) {
    final selected = selectedGoals.contains(goal);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            selectedGoals.remove(goal);
          } else {
            selectedGoals.add(goal);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                goal,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

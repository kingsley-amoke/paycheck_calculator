import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/constants/app_colors.dart';
import 'package:paycheck_calculator/core/constants/enums.dart';
import 'package:paycheck_calculator/core/widgets/filing_status_label.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/fade_up_animation.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/title_text.dart';
import 'package:provider/provider.dart';

class SalaryPage extends StatelessWidget {
  const SalaryPage({
    super.key,
    required this.fadeAnims,
    required this.slideAnims,
  });

  final List<Animation<double>> fadeAnims;
  final List<Animation<Offset>> slideAnims;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeUpAnimation(
            fades: fadeAnims,
            slides: slideAnims,
            index: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Text(
                '\$${provider.income.toInt()}',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          FadeUpAnimation(
            fades: fadeAnims,
            slides: slideAnims,
            index: 2,
            child: const TitleText(
              text: 'What’s Your ',
              styledText: 'Annual Salary?',
            ),
          ),

          const SizedBox(height: 24),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              thumbColor: AppColors.primary,
            ),
            child: Slider(
              min: 10000,
              max: 250000,
              value: provider.income,
              onChanged: (value) {
                provider.setIncome(value);
              },
            ),
          ),

          const SizedBox(height: 24),

          _filingStatusCard(provider, FilingStatus.single),
          const SizedBox(height: 8),
          _filingStatusCard(provider, FilingStatus.marriedJointly),
          const SizedBox(height: 8),
          _filingStatusCard(provider, FilingStatus.marriedSeparately),
          const SizedBox(height: 8),
          _filingStatusCard(provider, FilingStatus.headOfHousehold),
        ],
      ),
    );
  }
}

Widget _filingStatusCard(CalculatorProvider provider, FilingStatus value) {
  final selected = provider.filingStatus == value;

  return GestureDetector(
    onTap: () {
      provider.setFilingStatus(value);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
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
              filingStatusToLabel(value),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          if (selected)
            const Icon(Icons.check_circle, color: AppColors.primary),
        ],
      ),
    ),
  );
}

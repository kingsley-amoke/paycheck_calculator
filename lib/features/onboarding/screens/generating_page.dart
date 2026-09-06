import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/constants/app_colors.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/subtitle_text.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/title_text.dart';
import 'package:paycheck_calculator/features/paywall/purchase_view.dart';
import 'package:provider/provider.dart';

class GeneratingPage extends StatefulWidget {
  const GeneratingPage({super.key});

  @override
  State<GeneratingPage> createState() => _GeneratingPageState();
}

class _GeneratingPageState extends State<GeneratingPage> {
  @override
  void initState() {
    super.initState();
    _generateIncome();
  }

  Future<void> _generateIncome() async {
    await context.read<CalculatorProvider>().calculate();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PurchaseView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 5,
          ),

          const SizedBox(height: 48),

          const TitleText(
            text: 'Generating Your ',
            styledText: 'Personalized Report',
          ),

          const SizedBox(height: 24),

          const SubtitleText(
            text:
                'Analyzing taxes, deductions, effective tax rates, and take-home pay estimates...',
          ),
        ],
      ),
    );
  }
}

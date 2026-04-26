import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/deduction_item.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:provider/provider.dart';

class DeductionsSection extends StatelessWidget {
  const DeductionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<CalculatorProvider>();

    final country = provider.country;
    final resultA = provider.resultA!;
    final resultB = provider.resultB!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.5),
        border: Border.symmetric(
          horizontal: BorderSide(color: cs.outlineVariant, width: 0.8),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: resultA.deductions.length,
              physics: const NeverScrollableScrollPhysics(),

              shrinkWrap: true,
              itemBuilder: (_, index) {
                final deduction = resultA.deductions[index];
                final ratioA = resultA.grossIncome > 0
                    ? (deduction.amount / resultA.grossIncome).clamp(0.0, 1.0)
                    : 0.0;
                return DeductionItem(
                  deduction: deduction,
                  country: country,
                  ratio: ratioA,
                  color: cs.error,
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ListView.builder(
              itemCount: resultB.deductions.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (_, index) {
                final deduction = resultB.deductions[index];

                final ratioB = resultB.grossIncome > 0
                    ? (deduction.amount / resultB.grossIncome).clamp(0.0, 1.0)
                    : 0.0;
                return DeductionItem(
                  deduction: deduction,
                  country: country,
                  ratio: ratioB,
                  color: deduction.amount == 0 ? cs.secondary : cs.error,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

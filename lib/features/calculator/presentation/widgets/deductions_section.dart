// import 'package:flutter/material.dart';
// import 'package:paycheck_calculator/features/calculator/presentation/widgets/deduction_item.dart';
// import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
// import 'package:provider/provider.dart';

// class DeductionsSection extends StatelessWidget {
//   const DeductionsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     final provider = context.watch<CalculatorProvider>();

//     final country = provider.country;
//     final resultA = provider.resultA!;
//     final resultB = provider.resultB!;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       decoration: BoxDecoration(
//         color: cs.surface.withValues(alpha: 0.5),
//         border: Border.symmetric(
//           horizontal: BorderSide(color: cs.outlineVariant, width: 0.8),
//         ),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//       child: Row(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: resultA.deductions.length,
//               physics: const NeverScrollableScrollPhysics(),

//               shrinkWrap: true,
//               itemBuilder: (_, index) {
//                 final deduction = resultA.deductions[index];
//                 final ratioA = resultA.grossIncome > 0
//                     ? (deduction.amount / resultA.grossIncome).clamp(0.0, 1.0)
//                     : 0.0;
//                 return DeductionItem(
//                   deduction: deduction,
//                   country: country,
//                   ratio: ratioA,
//                   color: cs.error,
//                 );
//               },
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: ListView.builder(
//               itemCount: resultB.deductions.length,
//               physics: const NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               itemBuilder: (_, index) {
//                 final deduction = resultB.deductions[index];

//                 final ratioB = resultB.grossIncome > 0
//                     ? (deduction.amount / resultB.grossIncome).clamp(0.0, 1.0)
//                     : 0.0;
//                 return DeductionItem(
//                   deduction: deduction,
//                   country: country,
//                   ratio: ratioB,
//                   color: deduction.amount == 0 ? cs.secondary : cs.error,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/deduction_item.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:provider/provider.dart';

class DeductionsSection extends StatelessWidget {
  const DeductionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final provider = context.watch<CalculatorProvider>();

    final country = provider.country;
    final resultA = provider.resultA!;
    final resultB = provider.resultB!;

    final totalA = resultA.deductions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final totalB = resultB.deductions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    final hasDeductions =
        resultA.deductions.isNotEmpty || resultB.deductions.isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasDeductions
              ? cs.error.withValues(alpha: 0.25)
              : cs.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 24,
                  color: cs.onErrorContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deductions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Taxes and other deductions',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hasDeductions
                      ? cs.errorContainer
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasDeductions ? 'Calculated' : 'No deductions',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: hasDeductions
                        ? cs.onErrorContainer
                        : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Summary panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: cs.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated deductions',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Review the deductions included in each calculation.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Side-by-side calculation summaries
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DeductionColumn(
                  title: 'Calculation A',
                  total: totalA,
                  deductions: resultA.deductions,
                  grossIncome: resultA.grossIncome,
                  country: country,
                  color: cs.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DeductionColumn(
                  title: 'Calculation B',
                  total: totalB,
                  deductions: resultB.deductions,
                  grossIncome: resultB.grossIncome,
                  country: country,
                  color: cs.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeductionColumn extends StatelessWidget {
  const _DeductionColumn({
    required this.title,
    required this.total,
    required this.deductions,
    required this.grossIncome,
    required this.country,
    required this.color,
  });

  final String title;
  final double total;
  final List deductions;
  final double grossIncome;
  final dynamic country;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            total.toStringAsFixed(2),
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (deductions.isEmpty)
            Text(
              'No deductions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            )
          else
            ...deductions.map((deduction) {
              final ratio = grossIncome > 0
                  ? (deduction.amount / grossIncome).clamp(0.0, 1.0)
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DeductionItem(
                  deduction: deduction,
                  country: country,
                  ratio: ratio,
                  color: deduction.amount == 0 ? cs.secondary : color,
                ),
              );
            }),
        ],
      ),
    );
  }
}

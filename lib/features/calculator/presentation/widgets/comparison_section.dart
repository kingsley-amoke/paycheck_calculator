import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/deductions_section.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/empty_compare_hint.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/section_header.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/paycheck_result.dart';
import '../../provider/calculator_provider.dart';
import 'netpay_hero.dart';

class ComparisonSection extends StatelessWidget {
  const ComparisonSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<CalculatorProvider>();

    if (provider.resultB == null || provider.resultA == null) {
      return EmptyCompareHint();
    }

    if (provider.taxConfig?.regions == null) {
      return EmptyCompareHint();
    }

    PaycheckResult resultA = provider.resultA!;
    PaycheckResult resultB = provider.resultB!;

    final netDiff = provider.resultB!.netIncome - provider.resultA!.netIncome;
    final netPct = provider.resultA!.netIncome > 0
        ? (netDiff / provider.resultA!.netIncome * 100)
        : 0.0;
    final bIsBetter = netDiff > 0;
    final winner = bIsBetter ? provider.regionB : provider.regionA;
    final saving = netDiff.abs();

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: NetPayHero(
                    result: resultA,
                    country: provider.country,
                    isWinner: !bIsBetter,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: NetPayHero(
                    result: resultB,
                    country: provider.country,
                    isWinner: bIsBetter,
                    pctBadge:
                        '${netPct >= 0 ? '+' : ''}${netPct.toStringAsFixed(1)}%',
                  ),
                ),
              ],
            ),
          ),

          // ── Savings Banner ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: _SavingsBanner(
              winner: winner!.name,
              saving: saving,
              country: provider.country,
            ),
          ),

          const _BentoDivider(),

          // ── Gross Income ──
          _BentoRow(
            label: 'Gross Income',
            valueA: CurrencyFormatter.format(
              resultA.grossIncome,
              provider.country,
            ),
            valueB: CurrencyFormatter.format(
              resultB.grossIncome,
              provider.country,
            ),
          ),

          DeductionsSection(),

          // ── Effective Rate ──
          _BentoRow(
            label: 'Effective Tax Rate',
            valueA: '${(resultA.effectiveTaxRate * 100).toStringAsFixed(2)}%',
            valueB: '${(resultB.effectiveTaxRate * 100).toStringAsFixed(2)}%',
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _SavingsBanner extends StatelessWidget {
  final String winner;
  final double saving;
  final Country country;

  const _SavingsBanner({
    required this.winner,
    required this.saving,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up_rounded, size: 16, color: cs.secondary),
          const SizedBox(width: 6),
          Text(
            'Saved ${CurrencyFormatter.format(saving, country)} in $winner',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: cs.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoRow extends StatelessWidget {
  final String label;
  final String valueA;
  final String valueB;

  const _BentoRow({
    required this.label,
    required this.valueA,
    required this.valueB,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(label),
                const SizedBox(height: 4),
                Text(
                  valueA,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(label),
                const SizedBox(height: 4),
                Text(
                  valueB,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: cs.onSurface,
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

class _BentoDivider extends StatelessWidget {
  const _BentoDivider();

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
  );
}

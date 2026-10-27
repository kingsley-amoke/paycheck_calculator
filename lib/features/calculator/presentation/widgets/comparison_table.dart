import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../provider/comparison_provider.dart';

typedef double _ValueFn(ComparisonRow row);

/// Metric comparison: one column per selected profile, vertical metric
/// rows. Horizontally scrollable so four columns stay readable on narrow
/// displays.
class ComparisonTable extends StatelessWidget {
  const ComparisonTable({super.key, required this.rows});

  final List<ComparisonRow> rows;

  @override
  Widget build(BuildContext context) {
    final country = rows.first.profile.country;
    final anyRegion = rows.any((r) => r.result.regionTaxAmount > 0);
    final anyExtra = rows.any((r) => r.result.extraTaxesTotal > 0);
    final regionLabel = rows
        .map((r) => r.region?.name)
        .firstWhere((n) => n != null, orElse: () => null);

    final incomeSpecs = <_MetricSpec>[
      _MetricSpec('Gross per pay period', rows,
          (r) => r.result.grossIncome / r.periodsInYear, true, country, null),
      _MetricSpec('Additional income', rows,
          (r) => r.result.additionalAnnualIncome / r.periodsInYear, true,
          country, null),
      _MetricSpec('Estimated net pay', rows,
          (r) => r.result.netIncome / r.periodsInYear, true, country, null),
      _MetricSpec('Federal income tax', rows,
          (r) => r.result.federalTax / r.periodsInYear, false, country, null,
          true),
      if (anyRegion)
        _MetricSpec(regionLabel ?? 'State tax', rows,
            (r) => r.result.regionTaxAmount / r.periodsInYear, false, country,
            null),
      if (anyExtra)
        _MetricSpec('Social Security / Medicare / other', rows,
            (r) => r.result.extraTaxesTotal / r.periodsInYear, false, country,
            null),
      _MetricSpec('Pre-tax deductions', rows,
          (r) => r.result.preTaxDeductions / r.periodsInYear, false, country,
          null),
      _MetricSpec('Post-tax deductions', rows,
          (r) => r.result.postTaxDeductions / r.periodsInYear, false, country,
          null),
      _MetricSpec('Annual gross', rows, (r) => r.result.grossIncome, true,
          country, null),
      _MetricSpec('Annual net', rows, (r) => r.result.netIncome, true, country,
          null),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder(
          horizontalInside: BorderSide(color: AppColors.divider),
        ),
        children: [
          _headerRow(),
          for (final s in incomeSpecs) _metricRow(s),
          _rateRow(),
        ],
      ),
    );
  }

  TableRow _headerRow() {
    return TableRow(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Text(
            'Metric',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textGray,
            ),
          ),
        ),
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Text(
              r.profile.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
      ],
    );
  }

  TableRow _metricRow(_MetricSpec s) {
    final best = s.bestIndex();
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGray,
                ),
              ),
              if (s.subtitle != null)
                Text(
                  s.subtitle!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textLight,
                  ),
                ),
            ],
          ),
        ),
        for (var i = 0; i < rows.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.cell(i),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                if (s.perCellAnnual)
                  Text(
                    '${CurrencyFormatter.format(s.valueOf(rows[i]) * rows[i].periodsInYear, s.country)} / year',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textLight,
                    ),
                  ),
                if (i == best && s.isIncome)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: _DeltaChip.best(),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  TableRow _rateRow() {
    return TableRow(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Text(
            'Effective withholding rate',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textGray,
            ),
          ),
        ),
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Text(
              '${(r.result.effectiveTaxRate * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
      ],
    );
  }
}

/// One metric row. "Best" = highest for income rows, lowest for tax rows.
/// Chips: '▲' marker on the best income cell; nothing on other cells so no
/// row ever compares apples to different-period oranges.
class _MetricSpec {
  _MetricSpec(
    this.label,
    this.rows,
    this.valueOf,
    this.isIncome,
    this.country,
    this.subtitle, [
    this.perCellAnnual = false,
  ]);

  final String label;
  final String? subtitle;
  final bool perCellAnnual;
  final List<ComparisonRow> rows;
  final _ValueFn valueOf;
  final bool isIncome;
  final Country country;

  int bestIndex() {
    var best = 0;
    for (var i = 1; i < rows.length; i++) {
      final better = isIncome
          ? valueOf(rows[i]) > valueOf(rows[best])
          : valueOf(rows[i]) < valueOf(rows[best]);
      if (better) best = i;
    }
    return best;
  }

  String cell(int i) =>
      CurrencyFormatter.format(valueOf(rows[i]), country);
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip.best();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        '▲ best',
        style: TextStyle(fontSize: 10, color: AppColors.secondary),
      ),
    );
  }
}

import '../../../../core/constants/enums.dart';
import '../../../../data/models/calculation_profile.dart';
import '../entities/paycheck_result.dart';
import 'pay_periods.dart';

class MonthlyProjectionPoint {
  final int month; // 1..12
  final double gross;
  final double net;

  const MonthlyProjectionPoint({
    required this.month,
    required this.gross,
    required this.net,
  });
}

/// Calendar projection of a profile's pay across the months of a year.
///
/// Method (documented, defensible):
/// - The engine's annual [annualResult] result is authoritative — no separate
///   tax approximation here.
/// - Per-month amounts follow the calendar pay dates from `payPeriodsByMonth`
///   (paydays anchored to Jan 1 for weekly/biweekly; monthly exactly one per
///   month; hourly treated as weekly cycles ×52).
/// - Annual-frequency salaries accrue evenly across all twelve months.
/// - Overtime / additional income are embedded in the engine's annual result,
///   so they spread across the same paydays; no per-source tax split is
///   invented (taxes apply to totals).
///
/// Years with a 27th biweekly payday are normalized to the engine's ×26
/// annualization by `payPeriodsByMonth`.
List<MonthlyProjectionPoint> projectYear(
  CalculationProfile profile,
  PaycheckResult annualResult, {
  int? year,
}) {
  final y = year ?? DateTime.now().year;
  final grossByPeriods =
      annualResult.grossIncome > 0 ? annualResult.grossIncome : 0.0;
  final netByPeriods = annualResult.netIncome > 0 ? annualResult.netIncome : 0.0;

  final periodsByMonth = payPeriodsByMonth(y, profile.payFrequency);
  final totalPeriods = periodsByMonth.fold(0.0, (s, v) => s + v);

  return [
    for (var m = 0; m < 12; m++)
      MonthlyProjectionPoint(
        month: m + 1,
        gross: totalPeriods > 0
            ? grossByPeriods * periodsByMonth[m] / totalPeriods
            : 0,
        net: totalPeriods > 0 ? netByPeriods * periodsByMonth[m] / totalPeriods : 0,
      ),
  ];
}

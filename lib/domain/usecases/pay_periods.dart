import '../../core/constants/enums.dart';

const int _hourlyPeriodsPerYear = 52; // 40h-week payroll cycles

int periodsPerYear(PayFrequency f) {
  switch (f) {
    case PayFrequency.hourly:
      return _hourlyPeriodsPerYear;
    case PayFrequency.weekly:
      return 52;
    case PayFrequency.biWeekly:
      return 26;
    case PayFrequency.monthly:
      return 12;
    case PayFrequency.annually:
      return 1;
  }
}

/// Pay periods landing in each calendar month of [year].
///
/// Weekly/biweekly paydays are anchored to January 1 of the year and walked at
/// the frequency interval (defensible without knowing the employer's actual
/// first payday; monthly counts are exact). Results sum to the year's total
/// period count, with 3-payday months where anchors fall twice inside a longer
/// month plus a trailing anchor.
List<double> payPeriodsByMonth(int year, PayFrequency f) {
  if (f == PayFrequency.monthly) return List<double>.filled(12, 1);
  if (f == PayFrequency.annually) return List<double>.filled(12, 1 / 12);

  final counts = List<double>.filled(12, 0);
  var day = DateTime(year, 1, 1);
  final end = DateTime(year + 1, 1, 1);
  final stepDays = f == PayFrequency.biWeekly ? 14 : 7;

  // Walks at most periodsPerYear(f) anchors: the engine annualizes with a
  // fixed period count (e.g. biweekly ×26), so years with an extra payday
  // are normalized into that count — totals always match the engine result.
  for (var i = 0; i < periodsPerYear(f); i++) {
    final payday = day.add(Duration(days: i * stepDays));
    if (!payday.isBefore(end)) break;
    counts[payday.month - 1] += 1;
  }
  return counts;
}

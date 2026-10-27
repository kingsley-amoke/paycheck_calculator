import 'package:flutter_test/flutter_test.dart';
import 'package:paycheck_calculator/core/constants/enums.dart';
import 'package:paycheck_calculator/domain/usecases/pay_periods.dart';

void main() {
  test('periodsPerYear has documented counts', () {
    expect(periodsPerYear(PayFrequency.hourly), 52);
    expect(periodsPerYear(PayFrequency.weekly), 52);
    expect(periodsPerYear(PayFrequency.biWeekly), 26);
    expect(periodsPerYear(PayFrequency.monthly), 12);
    expect(periodsPerYear(PayFrequency.annually), 1);
  });

  test('biweekly 2026 pay dates land 2–3 per month and total 26', () {
    final byMonth = payPeriodsByMonth(2026, PayFrequency.biWeekly);

    expect(byMonth, [3, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2]);
    expect(byMonth.reduce((a, b) => a + b), 26);
  });

  test('weekly 2026 totals 52 across months of 4s and 5s', () {
    final byMonth = payPeriodsByMonth(2026, PayFrequency.weekly);

    expect(byMonth.length, 12);
    expect(byMonth.reduce((a, b) => a + b), 52);
    expect(
      byMonth.contains(5),
      isTrue,
      reason: 'some months hold 5 weekly paydays',
    );
  });

  test('monthly frequency has one payday per month', () {
    final byMonth = payPeriodsByMonth(2026, PayFrequency.monthly);

    expect(byMonth, List.filled(12, 1));
  });

  test('annual frequency accrues evenly across twelve months', () {
    final byMonth = payPeriodsByMonth(2026, PayFrequency.annually);

    expect(byMonth.length, 12);
    expect(
      byMonth.reduce((a, b) => a + b),
      closeTo(1, 1e-9),
      reason: 'annual income accrues over the year',
    );
  });

  test('biweekly distribution is year-stable from a Jan 1 anchor', () {
    final byMonth2027 = payPeriodsByMonth(2027, PayFrequency.biWeekly);
    final byMonth2030 = payPeriodsByMonth(2030, PayFrequency.biWeekly);

    expect(byMonth2027.reduce((a, b) => a + b), 26);
    expect(
      byMonth2030,
      byMonth2027,
      reason:
          'day-of-month anchors (1,15,29…) repeat in every year, so the monthly shape is stable',
    );
  });
}

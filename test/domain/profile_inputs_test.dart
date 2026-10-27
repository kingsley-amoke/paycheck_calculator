import 'package:flutter_test/flutter_test.dart';
import 'package:paycheck_calculator/core/constants/enums.dart';
import 'package:paycheck_calculator/data/models/calculation_profile.dart';
import 'package:paycheck_calculator/domain/usecases/pay_periods.dart';
import 'package:paycheck_calculator/domain/usecases/profile_inputs.dart';

void main() {
  group('overtime resolution', () {
    test('explicit rate always wins over multiplier', () {
      final p = CalculationProfile(
        id: '1',
        name: 'x',
        hourlyRate: 30,
        overtime: const OvertimeInput(hoursPerPeriod: 4, explicitRate: 50, multiplier: 2),
      );
      expect(resolvedOvertimeRate(p), 50);
    });

    test('multiplier resolves against the profile hourly rate', () {
      final p = CalculationProfile(
        id: '1',
        name: 'x',
        payFrequency: PayFrequency.biWeekly,
        hourlyRate: 20,
        overtime: const OvertimeInput(hoursPerPeriod: 5, multiplier: 1.5),
      );
      expect(resolvedOvertimeRate(p), 30);
      expect(overtimeAnnual(p), 30 * 5 * 26, reason: 'biweekly profile: 26 periods');
    });

    test('salaried profile with multiplier-only overtime supports nothing', () {
      final p = CalculationProfile(
        id: '1',
        name: 'x',
        income: 120000,
        hourlyRate: 0,
        overtime: const OvertimeInput(hoursPerPeriod: 2, multiplier: 1.5),
      );
      expect(resolvedOvertimeRate(p), 0);
      expect(overtimeAnnual(p), 0);
    });

    test('salaried profile works when an explicit OT rate is provided', () {
      final p = CalculationProfile(
        id: '1',
        name: 'x',
        payFrequency: PayFrequency.annually,
        income: 120000,
        hourlyRate: 0,
        overtime: const OvertimeInput(hoursPerPeriod: 2, explicitRate: 55),
      );
      // annually = 1 period in the year
      expect(overtimeAnnual(p), closeTo(55 * 2 * periodsPerYear(PayFrequency.annually), 0.01));
    });
  });

  test('extra income: recurring counts per period, once-per-year counts once', () {
    final p = CalculationProfile(
      id: '1',
      name: 'x',
      payFrequency: PayFrequency.biWeekly,
      incomeItems: const [
        ExtraIncomeItem(id: 'a', name: 'Bonus per paycheck', amount: 100),
        ExtraIncomeItem(
          id: 'b',
          name: 'Yearly bonus',
          amount: 2600,
          occurrence: ExtraIncomeOccurrence.oncePerYear,
        ),
      ],
    );
    expect(extraIncomeAnnual(p), 100 * 26 + 2600);
  });

  test('percentage deductions use annual gross including other extras as base', () {
    final p = CalculationProfile(
      id: '1',
      name: 'x',
      payFrequency: PayFrequency.biWeekly,
      income: 2000, // ×26 = 52,000 base
      overtime: const OvertimeInput(hoursPerPeriod: 4, explicitRate: 60), // 4×60×26 = 6,240
      deductions: const [
        UserDeduction(id: 'd1', name: '401k', value: 10, isPercentage: true, preTax: true),
        UserDeduction(id: 'd2', name: 'Union', value: 50, preTax: true),
        UserDeduction(id: 'd3', name: 'Loan', value: 25, preTax: false),
      ],
    );

    final extras = extrasFor(p);
    // base = (52000 + 6240 gross incl. overtime) → 10% = 5824
    expect(extras.preTaxDeductionsAnnual, closeTo(5824 + 50, 0.01));
    expect(extras.postTaxDeductionsAnnual, 25);
    expect(extras.additionalAnnualGross, closeTo(6240, 0.01));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:paycheck_calculator/core/constants/enums.dart';
import 'package:paycheck_calculator/data/models/calculation_profile.dart';
import 'package:paycheck_calculator/domain/entities/deduction.dart';
import 'package:paycheck_calculator/domain/entities/paycheck_result.dart';
import 'package:paycheck_calculator/domain/usecases/annual_projection.dart';

PaycheckResult resultOf(double annualNet, double annualGross) => PaycheckResult(
      grossIncome: annualGross,
      netIncome: annualNet,
      totalTax: annualGross - annualNet,
      effectiveTaxRate: (annualGross - annualNet) / annualGross,
      deductions: const <Deduction>[],
    );

void main() {
  test('biweekly profile distributes paydays across months (2026)', () {
    final p = CalculationProfile(
      id: 'p',
      name: 'x',
      payFrequency: PayFrequency.biWeekly,
      income: 2000, // ×26 = 52000 annual
    );
    final annualNet = 40000.0;
    final points = projectYear(p, resultOf(annualNet, 52000), year: 2026);

    expect(points, hasLength(12));
    final julNet = points[6].net;
    final janNet = points[0].net;
    expect(janNet, julNet,
        reason: 'Jan and Jul 2026 each hold 3 of 26 biweekly paydays');
    final februaryNet = points[1].net;
    expect(februaryNet, closeTo(janNet * 2 / 3, 0.01),
        reason: 'February holds 2 of 26 paydays');
    final sum = points.fold(0.0, (s, pt) => s + pt.net);
    expect(sum, closeTo(annualNet, 1e-6),
        reason: 'the projection must sum to the engine annual result');
    final grossSum = points.fold(0.0, (s, pt) => s + pt.gross);
    expect(grossSum, closeTo(52000, 1e-6),
        reason: 'gross distributes identically');
  });

  test('monthly profile puts exactly one paycheck in each month', () {
    final p = CalculationProfile(
      id: 'p',
      name: 'x',
      payFrequency: PayFrequency.monthly,
      income: 5000,
    );
    final net = 3600.0;
    final points = projectYear(p, resultOf(net, 60000), year: 2026);

    expect(points.map((pt) => pt.net), everyElement(closeTo(300, 1e-9)));
  });

  test('annual salary accrues evenly across twelve months', () {
    final p = CalculationProfile(
      id: 'p',
      name: 'x',
      payFrequency: PayFrequency.annually,
      income: 104000,
    );
    final net = 78000.0;
    final points = projectYear(p, resultOf(net, 104000), year: 2026);

    expect(points.map((pt) => pt.net), everyElement(closeTo(6500, 1e-9)));
  });

  test('weekly profile sums to the annual net for any anchor year', () {
    for (final year in [2026, 2030]) {
      final p = CalculationProfile(
        id: 'p',
        name: 'x',
        payFrequency: PayFrequency.weekly,
        income: 1000,
      );
      final net = 26000.0;
      final points = projectYear(p, resultOf(net, 52000), year: year);
      expect(
        points.fold(0.0, (s, pt) => s + pt.net),
        closeTo(net, 1e-4),
      );
    }
  });
}

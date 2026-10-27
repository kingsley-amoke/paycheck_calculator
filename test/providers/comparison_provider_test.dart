import 'package:flutter_test/flutter_test.dart';
import 'package:paycheck_calculator/core/constants/enums.dart';
import 'package:paycheck_calculator/data/models/calculation_profile.dart';
import 'package:paycheck_calculator/features/calculator/provider/comparison_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  CalculationProfile profile(
    String id, {
    double income = 75000,
    double otHours = 0,
    double otRate = 30,
  }) =>
      CalculationProfile(
        id: id,
        name: 'Profile $id',
        country: Country.us,
        payFrequency: PayFrequency.biWeekly,
        income: income,
        overtime: otHours > 0
            ? OvertimeInput(hoursPerPeriod: otHours, explicitRate: otRate)
            : null,
      );

  test('toggle caps selection at 4', () {
    final p = ComparisonProvider();
    for (var i = 1; i <= 5; i++) {
      p.toggle('p$i');
    }
    expect(p.selectedIds, hasLength(4));
    expect(p.selectedIds.contains('p5'), isFalse);
  });

  test('toggle add/remove, clear, selectionCount', () {
    final p = ComparisonProvider();
    p.toggle('a');
    expect(p.selectionCount, 1);
    p.toggle('a');
    expect(p.selectionCount, 0);
    p.toggle('a');
    p.toggle('b');
    p.remove('a');
    expect(p.selectedIds, ['b']);
    p.clear();
    expect(p.selectionCount, 0);
  });

  test('computeRows uses the engine and does not mutate profiles', () async {
    final low = profile('low', income: 60000);
    final high = profile('high', income: 90000, otHours: 4);
    final lowBeforeUpdatedAt = low.updatedAt;
    final highBeforeUpdatedAt = high.updatedAt;
    final lowItemsBefore = low.incomeItems.toString();

    final p = ComparisonProvider();
    p.toggle('low');
    p.toggle('high');

    final rows = await p.computeRows([low, high]);
    expect(rows, hasLength(2));
    expect(rows.map((r) => r.profile.name), {'Profile low', 'Profile high'});

    final lowRow = rows.firstWhere((r) => r.profile.id == 'low');
    final highRow = rows.firstWhere((r) => r.profile.id == 'high');

    // engine-driven: higher income + overtime must yield higher gross and net
    expect(highRow.result.grossIncome, greaterThan(lowRow.result.grossIncome));
    expect(highRow.result.netIncome, greaterThan(lowRow.result.netIncome));
    // overtime raised the wage base -> FICA identical behavior from engine
    expect(lowRow.result.totalTax, greaterThan(0));

    // no mutation
    expect(low.updatedAt, lowBeforeUpdatedAt);
    expect(high.updatedAt, highBeforeUpdatedAt);
    expect(low.incomeItems.toString(), lowItemsBefore);
    expect(low.id, 'low');
  });

  test('computeRows with zero selections is empty', () async {
    final p = ComparisonProvider();
    expect(await p.computeRows([profile('x')]), isEmpty);
  });

  test('computeRows against missing/deleted ids is safe', () async {
    final p = ComparisonProvider();
    p.toggle('ghost');
    expect(await p.computeRows([]), isEmpty);
  });
}

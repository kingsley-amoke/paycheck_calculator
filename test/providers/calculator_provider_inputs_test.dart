import 'package:flutter_test/flutter_test.dart';
import 'package:paycheck_calculator/core/constants/enums.dart';
import 'package:paycheck_calculator/data/models/calculation_profile.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CalculatorProvider provider;

  setUp(() {
    provider = CalculatorProvider();
  });

  Future<void> settleInit() async {
    // init() loads tax config asynchronously before notifying once
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  test('adding income item raises reported annual net', () async {
    await settleInit();
    provider.frequency = PayFrequency.monthly;
    final before = provider.result!.netIncome;

    provider.addIncomeItem(const ExtraIncomeItem(
      id: 'i1',
      name: 'Bonus',
      amount: 833, // monthly profile: ×12 = ~9996 annual
    ));
    await Future<void>.delayed(Duration.zero);

    expect(provider.result!.netIncome, greaterThan(before));
    expect(provider.result!.additionalAnnualIncome, closeTo(833 * 12, 0.5));
  });

  test('pre-tax deduction lowers net but keeps FICA base untouched', () async {
    await settleInit();
    final before = provider.result!;
    final ficaBitsBefore =
        before.deductions.where((d) => d.name == 'Social Security' || d.name == 'Medicare').map((d) => d.amount).toList();

    provider.addDeduction(const UserDeduction(
      id: 'd1',
      name: 'Traditional 401k',
      value: 5000,
      preTax: true,
      kind: DeductionKind.traditional401k,
    ));
    await Future<void>.delayed(Duration.zero);

    final after = provider.result!;
    // US: SS would rise with income, Medicare too; with flat income they must
    // be identical because the pre-tax deduction only trims income-tax wages.
    final ficaBitsAfter =
        after.deductions.where((d) => d.name == 'Social Security' || d.name == 'Medicare').map((d) => d.amount).toList();
    expect(ficaBitsAfter, ficaBitsBefore);
    expect(after.netIncome, lessThan(before.netIncome));
  });

  test('overtime inputs flow through as additional gross', () async {
    await settleInit();
    provider.frequency = PayFrequency.weekly;
    final before = provider.result!.netIncome;

    provider.setOvertime(hoursPerPeriod: 5, multiplier: 1.5, hourlyRate: 25);
    await Future<void>.delayed(Duration.zero);

    expect(provider.result!.additionalAnnualIncome, closeTo((25 * 1.5) * 5 * 52, 0.5));
    expect(provider.result!.netIncome, greaterThan(before));
  });

  test('clearOvertime resets to zero extras', () async {
    await settleInit();
    provider.setOvertime(hoursPerPeriod: 5, multiplier: 1.5, hourlyRate: 25);
    await Future<void>.delayed(Duration.zero);
    provider.clearOvertime();
    await Future<void>.delayed(Duration.zero);

    expect(provider.result!.additionalAnnualIncome, 0);
  });
}

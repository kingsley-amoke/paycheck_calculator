import 'package:flutter_test/flutter_test.dart';
import 'package:paycheck_calculator/core/constants/enums.dart';
import 'package:paycheck_calculator/domain/calculators/us_calculator.dart';
import 'package:paycheck_calculator/domain/entities/paycheck_result.dart';
import 'package:paycheck_calculator/domain/usecases/tax_data_loader.dart';

late USCalculator calculator;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final config = await TaxDataLoader.load(Country.us);
    calculator = USCalculator(config);
  });

  double lineSum(PaycheckResult r, String name) => r.deductions
      .where((d) => d.name.startsWith(name))
      .fold(0.0, (s, d) => s + (d.amount > 0 ? d.amount : 0));

  PaycheckResult runRegion(String code, {double income = 75000}) {
    final region = calculator.config.regions!.items.firstWhere(
      (r) => r.code == code,
    );
    return calculator.calculate(
      income: income,
      frequency: PayFrequency.annually,
      filingStatus: FilingStatus.single,
      region: region,
    );
  }

  PaycheckResult runNoRegion({double income = 75000}) =>
      calculator.calculate(
        income: income,
        frequency: PayFrequency.annually,
        filingStatus: FilingStatus.single,
      );

  test('flat AZ: state tax honors its own standard deduction', () {
    final r = runRegion('AZ', income: 75000);
    // (75000 − 8350) × 0.025
    expect(lineSum(r, 'Arizona Tax'), closeTo((75000 - 8350) * 0.025, 0.01));
  });

  test('flat IL: state tax honors its exemption', () {
    final r = runRegion('IL', income: 75000);
    // (75000 − 2925) × 0.0495
    expect(lineSum(r, 'Illinois Tax'), closeTo((75000 - 2925) * 0.0495, 0.01));
  });

  test('federal income tax is not reduced by a region deduction', () {
    final noRegion = runNoRegion();
    final az = runRegion('AZ');
    final il = runRegion('IL');
    expect(lineSum(az, 'Income Tax'), lineSum(noRegion, 'Income Tax'));
    expect(lineSum(il, 'Income Tax'), lineSum(noRegion, 'Income Tax'));
  });

  test('progressive CA: region brackets tax income minus region deductions',
      () {
    final ca = runRegion('CA');
    final caRegion = calculator.config.regions!.items.firstWhere(
      (r) => r.code == 'CA',
    );
    final regionDeduction = (caRegion.standardDeduction?['single'] ?? 0) +
        (caRegion.personalExemption?['single'] ?? 0);
    final brackets = caRegion.filingStatuses!['single']!.brackets;
    // New-design region base: the (federal-style) taxable income minus the
    // region's own deductions.
    final taxable = 75000 -
        calculator.getStandardDeduction(FilingStatus.single) -
        calculator.getPersonalAllowance(75000, FilingStatus.single);
    final expected = calculator.calculateBrackets(
      (taxable - regionDeduction).clamp(0, double.infinity),
      brackets,
    );
    expect(lineSum(ca, 'California Tax'), closeTo(expected, 0.01));
  });

  test('flat region deduction cannot make state tax negative', () {
    final r = runRegion('CO', income: 8000); // std deduction 16100 > income
    expect(lineSum(r, 'Colorado Tax'), 0.0);
  });
}

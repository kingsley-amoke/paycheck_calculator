import 'package:flutter_test/flutter_test.dart';
import 'package:paycheck_calculator/core/constants/enums.dart';
import 'package:paycheck_calculator/data/models/tax_config.dart';
import 'package:paycheck_calculator/domain/calculators/us_calculator.dart';
import 'package:paycheck_calculator/domain/entities/calculation_extras.dart';
import 'package:paycheck_calculator/domain/entities/paycheck_result.dart';
import 'package:paycheck_calculator/domain/usecases/tax_data_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TaxConfig config;
  late USCalculator calculator;

  setUpAll(() async {
    config = await TaxDataLoader.load(Country.us);
    calculator = USCalculator(config);
  });

  double lineSum(PaycheckResult r, String startsWith) => r.deductions
      .where((d) => d.name.startsWith(startsWith))
      .fold(0.0, (s, d) => s + d.amount);

  PaycheckResult baseline({CalculationExtras? extras, double income = 75000}) =>
      calculator.calculate(
        income: income,
        frequency: PayFrequency.annually,
        filingStatus: FilingStatus.single,
        extras: extras,
      );

  test('extras: null reproduces existing engine totals exactly', () {
    before() => calculator.calculate(
      income: 75000,
      frequency: PayFrequency.annually,
      filingStatus: FilingStatus.single,
    );

    final plain = before();
    final withNull = baseline();

    expect(withNull.grossIncome, plain.grossIncome);
    expect(withNull.netIncome, plain.netIncome);
    expect(withNull.totalTax, plain.totalTax);
    expect(withNull.effectiveTaxRate, plain.effectiveTaxRate);
  });

  test('us config: Social Security carries the wage-base cap in JSON', () {
    final ss = config.extraTaxes.singleWhere((t) => t.name == 'Social Security');
    expect(ss.type, 'capped');
    expect(ss.cap, isNotNull);
    expect(ss.cap, greaterThan(0));
  });

  test('high earner: SS stops at the cap, Medicare taxes all wages', () {
    final r = baseline(income: 250000);

    // 0.062 × cap-from-JSON; recomputed here from the same config source.
    expect(
      lineSum(r, 'Social Security'),
      closeTo(config.extraTaxes
          .singleWhere((t) => t.name == 'Social Security')
          .cap! * 0.062, 0.01),
    );
    expect(lineSum(r, 'Medicare'), closeTo(250000 * 0.0145, 0.01));
  });

  test('additional annual gross flows through gross and net', () {
    final plain = baseline(income: 75000);
    final extra = baseline(
      income: 75000,
      extras: const CalculationExtras(additionalAnnualGross: 10000),
    );

    expect(extra.grossIncome, closeTo(plain.grossIncome + 10000, 0.01));
    expect(extra.totalTax, greaterThan(plain.totalTax));
    expect(
      extra.extraTaxesTotal,
      closeTo(plain.extraTaxesTotal + 10000 * 0.0765, 0.02),
      reason: 'extra payroll taxes scale with the raised wage base',
    );
    expect(extra.netIncome, closeTo(extra.grossIncome - extra.totalTax, 0.01));
  });

  test('pre-tax deduction lowers income tax but not FICA base', () {
    final plain = baseline();
    final with401k = baseline(
      extras: const CalculationExtras(preTaxDeductionsAnnual: 5000),
    );

    expect(
      lineSum(plain, 'Income Tax'),
      greaterThan(lineSum(with401k, 'Income Tax')),
    );
    expect(
      with401k.extraTaxesTotal,
      closeTo(plain.extraTaxesTotal, 0.01),
      reason:
          '401k lowers income-tax wages, not Social Security/Medicare wages',
    );
    expect(
      with401k.grossIncome -
          with401k.totalTax -
          with401k.preTaxDeductions -
          with401k.postTaxDeductions,
      with401k.netIncome,
      reason: 'pre-tax contributions leave the paycheck too',
    );
    expect(
      with401k.netIncome,
      lessThan(plain.netIncome),
      reason: 'contributed amount exceeds the withholding saving',
    );
  });

  test('post-tax deduction is subtracted from net only', () {
    final plain = baseline();
    final withPost = baseline(
      extras: const CalculationExtras(postTaxDeductionsAnnual: 1000),
    );

    expect(withPost.totalTax, closeTo(plain.totalTax, 0.01));
    expect(withPost.grossIncome, closeTo(plain.grossIncome, 0.01));
    expect(withPost.netIncome, closeTo(plain.netIncome - 1000, 0.01));
    expect(withPost.postTaxDeductions, 1000);
    expect(withPost.preTaxDeductions, 0);
  });

  test('zero income: no NaN effective tax rate', () {
    final r = baseline(income: 0);
    expect(r.effectiveTaxRate.isNaN, isFalse);
    expect(r.effectiveTaxRate, 0);
  });

  test('monthly frequency extras annualized through engine (hourly base)', () {
    // income given per month: engine normalizes ×12
    final perMonthExtra = CalculationExtras(additionalAnnualGross: 6200);
    final r = calculator.calculate(
      income: 5000,
      frequency: PayFrequency.monthly,
      filingStatus: FilingStatus.single,
      extras: perMonthExtra,
    );

    expect(r.grossIncome, closeTo(60000 + 6200, 0.01));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:paycheck_calculator/data/models/tax_config.dart';

void main() {
  test('TaxConfig parses the "deductions" key (Germany config shape)', () {
    final config = TaxConfig.fromJson({
      'country': 'de',
      'currency': 'EUR',
      'extraTaxes': <Object>[],
      'deductions': {'employeeAllowance': 1239, 'childAllowance': 250},
    });

    expect(config.deductions, isNotNull);
    expect(config.deductions!.employeeAllowance, 1239);
    expect(config.deductions!.childAllowance, 250);
  });

  test('TaxConfig leaves deductions null when key is absent', () {
    final config = TaxConfig.fromJson({
      'country': 'us',
      'currency': 'USD',
      'extraTaxes': <Object>[],
    });

    expect(config.deductions, isNull);
  });
}

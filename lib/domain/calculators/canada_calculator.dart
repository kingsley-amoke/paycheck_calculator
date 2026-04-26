import 'package:paycheck_calculator/domain/calculators/task_calculator.dart';
import '../../data/models/extra_tax.dart';

class CanadaCalculator extends TaxCalculator {
  CanadaCalculator(super.config);

  @override
  double calculateExtraTax(ExtraTax tax, double income) {
    if (tax.name == "Canada Pension Plan") {
      return income.clamp(0, tax.cap ?? 0) * (tax.rate ?? 0);
    }
    return super.calculateExtraTax(tax, income);
  }
}

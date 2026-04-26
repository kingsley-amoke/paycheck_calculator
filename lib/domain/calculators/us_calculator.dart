import 'package:paycheck_calculator/domain/calculators/task_calculator.dart';
import '../../core/constants/enums.dart';

class USCalculator extends TaxCalculator {
  USCalculator(super.config);

  @override
  double getPersonalAllowance(double annualIncome, FilingStatus? filingStatus) {
    return 0;
  }
}

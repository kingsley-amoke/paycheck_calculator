import 'package:paycheck_calculator/domain/calculators/task_calculator.dart';

import '../../core/constants/enums.dart';

class GermanyCalculator extends TaxCalculator {
  GermanyCalculator(super.config);

  @override
  double getStandardDeduction(
    FilingStatus? filingStatus, {
    int numberOfChildren = 0,
    int remoteWorkDays = 0,
    double alimonyPaid = 0,
    double pensionContribution = 0,
  }) {
    double deduction = 0;

    // 1️⃣ Base standard deduction from filing status
    if (config.filingStatuses != null && filingStatus != null) {
      deduction +=
          config
              .filingStatuses![super.mapStatus(filingStatus)]
              ?.standardDeduction ??
          0;
    }

    // 2️⃣ Employee allowance
    deduction += config.deductions?.employeeAllowance ?? 0;

    // 3️⃣ Child allowance
    deduction += (config.deductions?.childAllowance ?? 0) * numberOfChildren;

    // 4️⃣ Remote work deduction (capped)
    if (remoteWorkDays > 0) {
      final maxRemote = config.deductions?.remoteWorkMax ?? 0;
      final perDay = config.deductions?.remoteWorkPerDay ?? 0;
      deduction += (remoteWorkDays * perDay).clamp(0, maxRemote);
    }

    // 5️⃣ Alimony (capped)
    if (alimonyPaid > 0) {
      final maxAlimony = config.deductions?.alimonyMaxDeductible ?? 0;
      deduction += alimonyPaid.clamp(0, maxAlimony);
    }

    // 6️⃣ Pension contributions (capped)
    if (pensionContribution > 0) {
      final maxPension = filingStatus == FilingStatus.marriedJointly
          ? config.deductions!.pensionSchemeMaxDeductible * 2
          : config.deductions?.pensionSchemeMaxDeductible ?? 0;
      deduction += pensionContribution.clamp(0, maxPension);
    }

    return deduction;
  }
}

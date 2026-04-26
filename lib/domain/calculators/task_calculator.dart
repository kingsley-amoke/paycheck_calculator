import '../../core/constants/enums.dart';
import '../../data/models/extra_tax.dart';
import '../../data/models/region_tax.dart';
import '../../data/models/tax_bracket.dart';
import '../../data/models/tax_config.dart';
import '../entities/deduction.dart';
import '../entities/paycheck_result.dart';

abstract class TaxCalculator {
  final TaxConfig config;

  TaxCalculator(this.config);

  PaycheckResult calculate({
    required double income,
    required PayFrequency frequency,
    FilingStatus? filingStatus,
    RegionTax? region,
  }) {
    final annualIncome = _normalizeToAnnual(income, frequency);

    final brackets = getBrackets(filingStatus);

    double taxableIncome = annualIncome;

    // Apply standard deduction
    taxableIncome -= getStandardDeduction(filingStatus);

    // Apply personal allowance (can be overridden)
    double allowance = getPersonalAllowance(annualIncome, filingStatus);
    taxableIncome -= allowance;

    // Apply region-specific deductions (hook)
    taxableIncome = applyRegionDeductions(taxableIncome, filingStatus, region);

    taxableIncome = taxableIncome.clamp(0, double.infinity);

    // Calculate main tax (hook, can be overridden per country)
    final mainTax = calculateBrackets(taxableIncome, brackets);

    // Build deductions list
    final deductions = buildDeductions(mainTax, allowance);

    // Region-specific tax (hook)
    final regionTaxAmount = calculateRegionTax(
      taxableIncome,
      annualIncome,
      filingStatus,
      region,
      deductions,
    );

    // Extra taxes (hook)
    final extraTotal = calculateExtraTaxes(annualIncome, deductions);

    final totalTax = mainTax + regionTaxAmount + extraTotal;
    final netIncome = annualIncome - totalTax;

    return PaycheckResult(
      grossIncome: annualIncome,
      netIncome: netIncome,
      totalTax: totalTax,
      effectiveTaxRate: totalTax / annualIncome,
      deductions: deductions,
    );
  }

  // ---------------- Hooks for overriding ----------------

  List<TaxBracket> getBrackets(FilingStatus? filingStatus) {
    if (config.filingStatuses != null && filingStatus != null) {
      final statusConfig = config.filingStatuses![mapStatus(filingStatus)];

      if (statusConfig?.brackets != null) return statusConfig!.brackets;
    }
    return config.brackets!;
  }

  double getStandardDeduction(FilingStatus? filingStatus) {
    if (config.filingStatuses != null && filingStatus != null) {
      return config
              .filingStatuses![mapStatus(filingStatus)]
              ?.standardDeduction ??
          0;
    }
    return 0;
  }

  double getPersonalAllowance(double annualIncome, FilingStatus? filingStatus) {
    if (config.personalAllowance == null) return 0;

    double allowance = config.personalAllowance!.amount;
    final start = config.personalAllowance!.phaseOutStart;
    if (start != null && annualIncome > start) {
      double reduction = (annualIncome - start) / 2;
      allowance = (config.personalAllowance!.amount - reduction).clamp(
        0,
        config.personalAllowance!.amount,
      );
    }
    return allowance.clamp(0, config.personalAllowance!.amount);
  }

  double applyRegionDeductions(
    double taxableIncome,
    FilingStatus? filingStatus,
    RegionTax? region,
  ) {
    if (region == null) return taxableIncome;
    taxableIncome -= region.standardDeduction?[filingStatus?.name] ?? 0;
    taxableIncome -= region.personalExemption?[filingStatus?.name] ?? 0;
    return taxableIncome;
  }

  double calculateBrackets(double income, List<TaxBracket> brackets) {
    double tax = 0;
    for (var b in brackets) {
      if (income > b.min) {
        double upper = b.max ?? income;
        double taxable = (income < upper ? income : upper) - b.min;
        tax += taxable * b.rate;
      }
    }
    return tax;
  }

  List<Deduction> buildDeductions(double mainTax, double allowance) {
    final deductions = <Deduction>[];
    deductions.add(Deduction(name: "Income Tax", amount: mainTax));
    if (allowance > 0) {
      deductions.add(Deduction(name: "Personal Allowance", amount: -allowance));
    }
    return deductions;
  }

  double calculateRegionTax(
    double taxableIncome,
    double annualIncome,
    FilingStatus? filingStatus,
    RegionTax? region,
    List<Deduction> deductions,
  ) {
    if (region == null) return 0;

    double regionTaxAmount = 0;

    if (region.type == "flat") {
      regionTaxAmount = annualIncome * (region.rate ?? 0);
    } else if (region.filingStatuses != null) {
      final statusBrackets =
          region.filingStatuses![filingStatus?.name]?.brackets;
      if (statusBrackets != null) {
        regionTaxAmount = calculateBrackets(taxableIncome, statusBrackets);
      }
    } else if (region.brackets != null) {
      regionTaxAmount = calculateBrackets(taxableIncome, region.brackets!);
    }

    deductions.add(
      Deduction(name: "${region.name} Tax", amount: regionTaxAmount),
    );
    return regionTaxAmount;
  }

  double calculateExtraTaxes(double annualIncome, List<Deduction> deductions) {
    double total = 0;
    for (var tax in config.extraTaxes) {
      double value = calculateExtraTax(tax, annualIncome);
      total += value;
      deductions.add(Deduction(name: tax.name, amount: value));
    }
    return total;
  }

  double calculateExtraTax(ExtraTax tax, double income) {
    switch (tax.type) {
      case "flat":
        return income * (tax.rate ?? 0);
      case "capped":
        double base = income;
        if (tax.cap != null) base = base.clamp(0, tax.cap!);
        if (tax.deduction != null) base -= tax.deduction!;
        return base * (tax.rate ?? 0);
      case "progressive":
        return calculateBrackets(income, tax.brackets!);
      default:
        return 0;
    }
  }

  // ---------------- Helpers ----------------

  double _normalizeToAnnual(double income, PayFrequency freq) {
    switch (freq) {
      case PayFrequency.hourly:
        return income * 40 * 52;
      case PayFrequency.weekly:
        return income * 52;
      case PayFrequency.biWeekly:
        return income * 26;
      case PayFrequency.monthly:
        return income * 12;
      case PayFrequency.annually:
        return income;
    }
  }

  String mapStatus(FilingStatus status) {
    switch (status) {
      case FilingStatus.single:
        return "single";
      case FilingStatus.marriedJointly:
        return "married_jointly";
      case FilingStatus.marriedSeparately:
        return "married_separately";
      case FilingStatus.headOfHousehold:
        return "head_of_household";
    }
  }
}

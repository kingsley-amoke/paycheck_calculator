import './deduction.dart';

class PaycheckResult {
  final double grossIncome;
  final double netIncome;
  final double totalTax;
  final double effectiveTaxRate;
  final List<Deduction> deductions;

  /// Breakdown detail for comparison/projection surfaces.
  /// Total tax split; pre/post-tax user deduction totals; extra (payroll) taxes.
  final double federalTax;
  final double regionTaxAmount;
  final double extraTaxesTotal;
  final double preTaxDeductions;
  final double postTaxDeductions;
  final double additionalAnnualIncome;

  PaycheckResult({
    required this.grossIncome,
    required this.netIncome,
    required this.totalTax,
    required this.effectiveTaxRate,
    required this.deductions,
    this.federalTax = 0,
    this.regionTaxAmount = 0,
    this.extraTaxesTotal = 0,
    this.preTaxDeductions = 0,
    this.postTaxDeductions = 0,
    this.additionalAnnualIncome = 0,
  });
}

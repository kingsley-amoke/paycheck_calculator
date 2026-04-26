import 'deduction.dart';

class PaycheckResult {
  final double grossIncome;
  final double netIncome;
  final double totalTax;
  final double effectiveTaxRate;
  final List<Deduction> deductions;

  PaycheckResult({
    required this.grossIncome,
    required this.netIncome,
    required this.totalTax,
    required this.effectiveTaxRate,
    required this.deductions,
  });
}
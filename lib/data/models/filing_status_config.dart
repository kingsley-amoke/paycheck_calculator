import 'package:paycheck_calculator/data/models/tax_bracket.dart';

class FilingStatusConfig {
  final double? standardDeduction;
  final double? personalAllowance;
  final List<TaxBracket> brackets;

  FilingStatusConfig({
    this.standardDeduction,
    this.personalAllowance,
    required this.brackets,
  });

  factory FilingStatusConfig.fromJson(Map<String, dynamic> json) {
    return FilingStatusConfig(
      standardDeduction: json['standardDeduction']?.toDouble(),
      personalAllowance: json['personalAllowance']?.toDouble(),
      brackets: (json['brackets'] as List)
          .map((e) => TaxBracket.fromJson(e))
          .toList(),
    );
  }
}
import 'package:paycheck_calculator/data/models/tax_bracket.dart';

import 'filing_status_config.dart';

class RegionTax {
  final String name;
  final String code;
  final String type; // flat, progressive
  final double? rate;
  final List<TaxBracket>? brackets;
  final Map<String, FilingStatusConfig>? filingStatuses;
  final Map<String, int>? standardDeduction;
  final Map<String, int>? personalExemption;

  RegionTax({
    required this.name,
    required this.code,
    required this.type,
    this.rate,
    this.brackets,
    this.filingStatuses,
    this.personalExemption,
    this.standardDeduction,
  });

  factory RegionTax.fromJson(Map<String, dynamic> json) {
    return RegionTax(
      name: json['name'],
      code: json['code'],
      type: json['type'],
      rate: json['rate']?.toDouble(),
      brackets: json['brackets'] != null
          ? (json['brackets'] as List)
                .map((e) => TaxBracket.fromJson(e))
                .toList()
          : null,
      filingStatuses: json['filingStatuses'] != null
          ? (json['filingStatuses'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, FilingStatusConfig.fromJson(value)),
            )
          : null,
      standardDeduction: json['standardDeduction'] != null
          ? Map<String, int>.from(json['standardDeduction'])
          : null,

      personalExemption: json['personalExemption'] != null
          ? Map<String, int>.from(json['personalExemption'])
          : null,
    );
  }
}

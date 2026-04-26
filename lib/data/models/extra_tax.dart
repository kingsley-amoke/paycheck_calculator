import 'package:paycheck_calculator/data/models/tax_bracket.dart';

class ExtraTax {
  final String name;
  final String type; // flat, progressive, capped
  final double? rate;
  final double? cap;
  final double? deduction;
  final List<TaxBracket>? brackets;

  ExtraTax({
    required this.name,
    this.type = "flat",
    this.rate,
    this.cap,
    this.deduction,
    this.brackets,
  });

  factory ExtraTax.fromJson(Map<String, dynamic> json) {
    return ExtraTax(
      name: json['name'],
      type: json['type'] ?? 'flat',
      rate: json['rate'] != null ? (json['rate'] as num).toDouble() : null,
      cap: json['cap'] != null ? (json['cap'] as num).toDouble() : null,
      deduction: json['deduction'] != null
          ? (json['deduction'] as num).toDouble()
          : null,
      brackets: json['brackets'] != null
          ? (json['brackets'] as List)
          .map((e) => TaxBracket.fromJson(e))
          .toList()
          : null,
    );
  }
}
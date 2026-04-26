import 'package:paycheck_calculator/data/models/deductions.dart';
import 'package:paycheck_calculator/data/models/personal_tax_config.dart';
import 'package:paycheck_calculator/data/models/region_config.dart';
import 'package:paycheck_calculator/data/models/tax_bracket.dart';

import 'extra_tax.dart';
import 'filing_status_config.dart';

class TaxConfig {
  final String country;
  final String currency;
  final Map<String, FilingStatusConfig>? filingStatuses;
  final List<TaxBracket>? brackets;
  final List<ExtraTax> extraTaxes;
  final RegionConfig? regions;
  final PersonalAllowanceConfig? personalAllowance;
  final Deductions? deductions;

  TaxConfig({
    required this.country,
    required this.currency,
    this.filingStatuses,
    this.brackets,
    this.regions,
    required this.extraTaxes,
    this.personalAllowance,
    this.deductions,
  });

  factory TaxConfig.fromJson(Map<String, dynamic> json) {
    return TaxConfig(
      country: json['country'],
      currency: json['currency'],
      deductions: json['deduction'] != null
          ? Deductions.fromJson(json['deductions'])
          : null,
      regions: json['regions'] != null
          ? RegionConfig.fromJson(json['regions'])
          : null,
      filingStatuses: json['filingStatuses'] != null
          ? (json['filingStatuses'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, FilingStatusConfig.fromJson(value)),
            )
          : null,
      brackets: json['brackets'] != null
          ? (json['brackets'] as List)
                .map((e) => TaxBracket.fromJson(e))
                .toList()
          : null,
      personalAllowance: json['personalAllowance'] != null
          ? PersonalAllowanceConfig.fromJson(json['personalAllowance'])
          : null,
      extraTaxes: (json['extraTaxes'] as List)
          .map((e) => ExtraTax.fromJson(e))
          .toList(),
    );
  }
}

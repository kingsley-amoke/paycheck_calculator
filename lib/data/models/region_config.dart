import 'package:paycheck_calculator/data/models/region_tax.dart';

class RegionConfig {
  final String type; // state / province
  final List<RegionTax> items;

  RegionConfig({
    required this.type,
    required this.items,
  });

  factory RegionConfig.fromJson(Map<String, dynamic> json) {
    return RegionConfig(
      type: json['type'],
      items: (json['items'] as List)
          .map((e) => RegionTax.fromJson(e))
          .toList(),
    );
  }
}
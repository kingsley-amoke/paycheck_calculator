import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/constants/enums.dart';
import '../../data/models/tax_config.dart';

class TaxDataLoader {
  static Future<TaxConfig> load(Country country) async {
    final fileName = country.name; // us.json, uk.json

    final jsonString =
    await rootBundle.loadString('assets/taxes/$fileName.json');

    final jsonMap = json.decode(jsonString);

    return TaxConfig.fromJson(jsonMap);
  }
}
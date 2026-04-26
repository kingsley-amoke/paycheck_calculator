import 'package:paycheck_calculator/domain/usecases/tax_data_loader.dart';
import '../../core/constants/enums.dart';
import '../calculators/australia_calculator.dart';
import '../calculators/canada_calculator.dart';
import '../calculators/germany_calculator.dart';
import '../calculators/task_calculator.dart';
import '../calculators/uk_calculator.dart';
import '../calculators/us_calculator.dart';

class TaxCalculatorFactory {
  static Future<TaxCalculator> get(Country country) async {
    final config = await TaxDataLoader.load(country);

    switch (country) {
      case Country.us:
        return USCalculator(config);
      case Country.ca:
        return CanadaCalculator(config);
      case Country.uk:
        return UKCalculator(config);
      case Country.au:
        return AustraliaCalculator(config);

      case Country.de:
        return GermanyCalculator(config);
    }
  }
}

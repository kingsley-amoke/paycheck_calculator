import 'package:paycheck_calculator/core/constants/enums.dart';

String countryLabel(Country f) {
  switch (f) {
    case Country.us:
      return "United States";
    case Country.uk:
      return "United Kingdom";
    case Country.au:
      return "Australia";
    case Country.de:
      return "Germany";
    case Country.ca:
      return "Canada";
  }
}

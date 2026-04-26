import 'package:intl/intl.dart';
import '../constants/enums.dart';

class CurrencyFormatter {
  static String format(double amount, Country country) {
    switch (country) {
      case Country.us:
        return NumberFormat.currency(symbol: '\$').format(amount);
      case Country.uk:
        return NumberFormat.currency(symbol: '£').format(amount);
      case Country.ca:
        return NumberFormat.currency(symbol: 'CA\$').format(amount);
      case Country.au:
        return NumberFormat.currency(symbol: 'A\$').format(amount);
      case Country.de:
        return NumberFormat.currency(symbol: '€').format(amount);
    }
  }
}

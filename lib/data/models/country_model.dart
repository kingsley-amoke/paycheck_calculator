import '../../core/constants/enums.dart';

class CountryOption {
  final Country country;
  final String name;
  final String flag;
  final String currency;
  final String currencySymbol;

  CountryOption({
    required this.country,
    required this.name,
    required this.flag,
    required this.currency,
    required this.currencySymbol,
  });
}

import '../../data/models/country_model.dart';
import 'enums.dart';

final flags = ['🇺🇸', '🇬🇧', '🇨🇦', '🇦🇺'];

final countries = [
  CountryOption(
    country: Country.us,
    name: "United States",
    flag: '🇺🇸',
    currency: 'USD',
    currencySymbol: '\$',
  ),
  CountryOption(
    country: Country.uk,
    name: "United Kingdom",
    flag: '🇬🇧',
    currency: 'GBP',
    currencySymbol: '£',
  ),
  CountryOption(
    country: Country.ca,
    name: "Canada",
    flag: '🇨🇦',
    currency: 'CAD',
    currencySymbol: '\$',
  ),
  CountryOption(
    country: Country.au,
    name: "Australia",
    flag: '🇦🇺',
    currency: 'AUD',
    currencySymbol: '\$',
  ),
  CountryOption(
    country: Country.de,
    name: "Germany",
    flag: '🇩🇪',
    currency: 'EUR',
    currencySymbol: '€',
  ),
];

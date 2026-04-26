import '../../data/models/country_model.dart';
import 'enums.dart';

final flags = ['🇺🇸', '🇬🇧', '🇨🇦', '🇦🇺',];

final countries = [
  CountryOption(
    country: Country.us,
    name: "United States",
    flag: '🇺🇸',
    currency: 'USD',
  ),
  CountryOption(
    country: Country.uk,
    name: "United Kingdom",
    flag: '🇬🇧',
    currency: 'GBP',
  ),
  CountryOption(
    country: Country.ca,
    name: "Canada",
    flag: '🇨🇦',
    currency: 'CAD',
  ),
  CountryOption(
    country: Country.au,
    name: "Australia",
    flag: '🇦🇺',
    currency: 'AUD',
  ), CountryOption(
    country: Country.de,
    name: "Germany",
    flag: '🇩🇪',
    currency: 'EUR',
  ),

];
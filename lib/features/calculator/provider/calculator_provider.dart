import 'package:flutter/material.dart';
import 'package:paycheck_calculator/data/models/tax_config.dart';
import '../../../core/constants/enums.dart';
import '../../../data/models/region_tax.dart';
import '../../../domain/entities/paycheck_result.dart';
import '../../../domain/usecases/hourly_converter.dart';
import '../../../domain/usecases/tax_calculator_factory.dart';
import '../../../domain/usecases/tax_data_loader.dart';

class CalculatorProvider extends ChangeNotifier {
  double income = 0;
  PayFrequency frequency = PayFrequency.annually;
  Country country = Country.us;

  // Hourly converter inputs
  double hourlyRate = 25;
  double hoursPerWeek = 40;

  PaycheckResult? result;
  PaycheckResult? resultA;
  PaycheckResult? resultB;

  RegionTax? selectedRegion;
  RegionTax? regionA;
  RegionTax? regionB;
  TaxConfig? taxConfig;

  // 🔥 MAIN CALCULATION
  FilingStatus filingStatus = FilingStatus.single;

  CalculatorProvider() {
    init();
  }

  Future<void> init() async {
    taxConfig = await TaxDataLoader.load(country);

    if (taxConfig?.regions != null) {
      selectedRegion = taxConfig!.regions!.items.first;
    }

    calculate();
  }

  void setRegion(RegionTax region) {
    selectedRegion = region;
    calculate();
  }

  void setRegionA(RegionTax region) {
    regionA = region;
    compare();
    notifyListeners();
  }

  void setRegionB(RegionTax region) {
    regionB = region;
    compare();
    notifyListeners();
  }

  void setFilingStatus(FilingStatus status) {
    filingStatus = status;

    calculate();
    compare();
  }

  Future<void> calculate() async {
    final calculator = await TaxCalculatorFactory.get(country);

    result = calculator.calculate(
      income: income,
      frequency: frequency,
      filingStatus: filingStatus,
      region: selectedRegion,
    );

    notifyListeners();
  }

  Future<void> compare() async {
    if (regionA == null || regionB == null) return;
    final calculator = await TaxCalculatorFactory.get(country);

    resultA = calculator.calculate(
      income: income,
      frequency: frequency,
      filingStatus: filingStatus,
      region: regionA,
    );

    resultB = calculator.calculate(
      income: income,
      frequency: frequency,
      filingStatus: filingStatus,
      region: regionB,
    );
    notifyListeners();
  }

  // 🔄 UPDATE INPUTS
  void setIncome(double value) {
    income = value;
    calculate();
    compare();
  }

  void setFrequency(PayFrequency value) {
    frequency = value;
    calculate();
    compare();
    notifyListeners();
  }

  void setCountry(Country value) async {
    country = value;
    taxConfig = await TaxDataLoader.load(country);

    if (taxConfig?.regions != null) {
      selectedRegion = taxConfig!.regions!.items.first;
      regionA = taxConfig!.regions!.items.first;
      regionB = taxConfig!.regions!.items.last;
    } else {
      selectedRegion = null;
    }

    calculate();
    notifyListeners();
  }

  // 🔥 HOURLY CONVERSION
  double get weeklyPay => HourlyConverter.toWeekly(hourlyRate, hoursPerWeek);

  double get monthlyPay => HourlyConverter.toMonthly(hourlyRate, hoursPerWeek);

  double get annualPay => HourlyConverter.toAnnual(hourlyRate, hoursPerWeek);

  void setHourlyRate(double value) {
    hourlyRate = value;
    notifyListeners();
  }

  void setHoursPerWeek(double value) {
    hoursPerWeek = value;
    notifyListeners();
  }
}

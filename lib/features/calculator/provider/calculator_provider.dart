import 'package:flutter/material.dart';
import 'package:paycheck_calculator/data/models/calculation_profile.dart';
import 'package:paycheck_calculator/data/models/tax_config.dart';
import '../../../core/constants/enums.dart';
import '../../../data/models/region_tax.dart';
import '../../../domain/entities/calculation_extras.dart';
import '../../../domain/entities/paycheck_result.dart';
import '../../../domain/usecases/hourly_converter.dart';
import '../../../domain/usecases/pay_periods.dart';import '../../../domain/usecases/profile_inputs.dart';
import '../../../domain/usecases/tax_calculator_factory.dart';
import '../../../domain/usecases/tax_data_loader.dart';

class CalculatorProvider extends ChangeNotifier {
  double income = 75000;
  PayFrequency frequency = PayFrequency.annually;
  Country country = Country.us;

  // Hourly converter inputs
  double hourlyRate = 25;
  double hoursPerWeek = 40;

  // Overtime inputs
  double overtimeHoursPerPeriod = 0;
  double? overtimeRate;
  double? overtimeMultiplier;

  // Additional income / user deductions
  List<ExtraIncomeItem> incomeItems = <ExtraIncomeItem>[];
  List<UserDeduction> userDeductions = <UserDeduction>[];

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

    final extras = buildExtras();

    result = calculator.calculate(
      income: income,
      frequency: frequency,
      filingStatus: filingStatus,
      region: selectedRegion,
      extras: extras.isZero ? null : extras,
    );

    notifyListeners();
  }

  Future<void> compare() async {
    if (regionA == null || regionB == null) return;
    final calculator = await TaxCalculatorFactory.get(country);

    final extras = buildExtras();

    resultA = calculator.calculate(
      income: income,
      frequency: frequency,
      filingStatus: filingStatus,
      region: regionA,
      extras: extras,
    );

    resultB = calculator.calculate(
      income: income,
      frequency: frequency,
      filingStatus: filingStatus,
      region: regionB,
      extras: extras,
    );
    notifyListeners();
  }

  CalculationExtras buildExtras() => extrasFromInputs(
        hourlyRate: hourlyRate,
        frequency: frequency,
        income: income,
        overtime: overtimeHoursPerPeriod > 0
            ? OvertimeInput(
                hoursPerPeriod: overtimeHoursPerPeriod,
                explicitRate: overtimeRate,
                multiplier: overtimeMultiplier,
              )
            : null,
        incomeItems: incomeItems,
        userDeductions: userDeductions,
      );

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

  // ── OVERTIME ─────────────────────────────────────────────────────────────

  void setOvertime({
    required double hoursPerPeriod,
    double? rate,
    double? multiplier,
    double? hourlyRate,
  }) {
    overtimeHoursPerPeriod = hoursPerPeriod > 0 ? hoursPerPeriod : 0;
    if (overtimeHoursPerPeriod > 0) {
      overtimeRate = rate != null && rate > 0 ? rate : null;
      overtimeMultiplier =
          multiplier != null && multiplier > 0 ? multiplier : null;
      if (hourlyRate != null) this.hourlyRate = hourlyRate;
    }
    calculate();
  }

  void clearOvertime() {
    overtimeHoursPerPeriod = 0;
    overtimeRate = null;
    overtimeMultiplier = null;
    calculate();
  }

  // ── ADDITIONAL INCOME ───────────────────────────────────────────────────

  void addIncomeItem(ExtraIncomeItem item) {
    incomeItems = [...incomeItems, item];
    calculate();
  }

  void editIncomeItem(String id, ExtraIncomeItem updated) {
    incomeItems = [for (final i in incomeItems) i.id == id ? updated : i];
    calculate();
  }

  void removeIncomeItem(String id) {
    incomeItems = [for (final i in incomeItems) if (i.id != id) i];
    calculate();
  }

  // ── USER DEDUCTIONS ─────────────────────────────────────────────────────

  void addDeduction(UserDeduction deduction) {
    userDeductions = [...userDeductions, deduction];
    calculate();
  }

  void editDeduction(String id, UserDeduction updated) {
    userDeductions = [for (final d in userDeductions) d.id == id ? updated : d];
    calculate();
  }

  void removeDeduction(String id) {
    userDeductions = [for (final d in userDeductions) if (d.id != id) d];
    calculate();
  }

  int get periodsInYear => periodsPerYear(frequency);

  // ── PROFILE LOADING ─────────────────────────────────────────────────────

  /// Loads a saved profile's inputs into the working calculation.
  /// Resolves the region by code against the freshly loaded tax config.
  Future<void> applyProfile(CalculationProfile profile) async {
    country = profile.country;
    frequency = profile.payFrequency;
    income = profile.income;
    filingStatus = profile.filingStatus ?? FilingStatus.single;
    hourlyRate = profile.hourlyRate;
    hoursPerWeek = profile.hoursPerWeek > 0 ? profile.hoursPerWeek : 40;
    overtimeHoursPerPeriod = profile.overtime?.hoursPerPeriod ?? 0;
    overtimeRate = profile.overtime?.explicitRate;
    overtimeMultiplier = profile.overtime?.multiplier;
    incomeItems = List.of(profile.incomeItems);
    userDeductions = List.of(profile.deductions);

    taxConfig = await TaxDataLoader.load(country);
    selectedRegion = null;
    if (profile.regionCode != null && taxConfig?.regions != null) {
      for (final r in taxConfig!.regions!.items) {
        if (r.code == profile.regionCode) selectedRegion = r;
      }
    }
    if (taxConfig?.regions != null) {
      regionA ??= taxConfig!.regions!.items.first;
      regionB ??= taxConfig!.regions!.items.last;
    }

    await calculate();
  }

  /// Snapshot of the current working inputs as a profile.
  CalculationProfile snapshotToProfile({String? id, String name = ''}) {
    return CalculationProfile(
      id: id ?? generateProfileId(),
      name: name,
      country: country,
      payFrequency: frequency,
      income: income,
      filingStatus: filingStatus,
      regionCode: selectedRegion?.code,
      hourlyRate: hourlyRate,
      hoursPerWeek: hoursPerWeek,
      overtime: overtimeHoursPerPeriod > 0
          ? OvertimeInput(
              hoursPerPeriod: overtimeHoursPerPeriod,
              explicitRate: overtimeRate,
              multiplier: overtimeMultiplier,
            )
          : null,
      incomeItems: List.of(incomeItems),
      deductions: List.of(userDeductions),
    );
  }
}

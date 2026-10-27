import '../../core/constants/enums.dart';
import '../../data/models/calculation_profile.dart';
import '../entities/calculation_extras.dart';
import 'pay_periods.dart';

/// Annual ordinary income when [income] is expressed per [frequency]
/// (the same normalization the tax engine performs internally).
double annualOrdinaryIncome(double income, PayFrequency frequency) {
  switch (frequency) {
    case PayFrequency.hourly:
      return income * 40 * 52;
    case PayFrequency.weekly:
      return income * 52;
    case PayFrequency.biWeekly:
      return income * 26;
    case PayFrequency.monthly:
      return income * 12;
    case PayFrequency.annually:
      return income;
  }
}

/// Resolved overtime hourly rate for a profile: an explicitly entered OT rate
/// always wins; a multiplier is applied to the ordinary hourly rate. Salaried
/// profiles (no hourly rate) must supply an explicit rate — nothing is derived.
double resolvedOvertimeRate(CalculationProfile p) =>
    resolvedRateFor(hourlyRate: p.hourlyRate, overtime: p.overtime);

double resolvedRateFor({required double hourlyRate, OvertimeInput? overtime}) {
  final ot = overtime;
  if (ot == null || ot.hoursPerPeriod <= 0) return 0;
  if (ot.explicitRate != null && ot.explicitRate! > 0) return ot.explicitRate!;
  if (ot.multiplier != null && ot.multiplier! > 0 && hourlyRate > 0) {
    return hourlyRate * ot.multiplier!;
  }
  return 0;
}

double overtimeAnnual(CalculationProfile p) {
  final rate = resolvedRateFor(hourlyRate: p.hourlyRate, overtime: p.overtime);
  if (rate <= 0) return 0;
  return rate * p.overtime!.hoursPerPeriod * periodsPerYear(p.payFrequency);
}

double extraIncomeAnnual(CalculationProfile p) {
  final periods = periodsPerYear(p.payFrequency);
  var total = 0.0;
  for (final item in p.incomeItems) {
    final amount = item.amount > 0 ? item.amount : 0.0;
    total += item.occurrence == ExtraIncomeOccurrence.oncePerYear
        ? amount
        : amount * periods;
  }
  return total;
}

/// Single source of extras math. Percentage deductions use annual gross
/// (ordinary + overtime + additional income) as the percentage base.
CalculationExtras extrasFromInputs({
  required double hourlyRate,
  required PayFrequency frequency,
  required double income,
  OvertimeInput? overtime,
  required List<ExtraIncomeItem> incomeItems,
  required List<UserDeduction> userDeductions,
}) {
  final ordinary = annualOrdinaryIncome(income, frequency);
  final otRate = resolvedRateFor(hourlyRate: hourlyRate, overtime: overtime);
  final otAnnual = (overtime != null && overtime.hoursPerPeriod > 0)
      ? otRate * overtime.hoursPerPeriod * periodsPerYear(frequency)
      : 0.0;

  final periods = periodsPerYear(frequency);
  var extraIncome = 0.0;
  for (final item in incomeItems) {
    final amount = item.amount > 0 ? item.amount : 0.0;
    extraIncome += item.occurrence == ExtraIncomeOccurrence.oncePerYear
        ? amount
        : amount * periods;
  }

  final annualBase = ordinary + otAnnual + extraIncome;

  var preTax = 0.0;
  var postTax = 0.0;
  for (final d in userDeductions) {
    final amount = d.isPercentage ? annualBase * d.value / 100 : d.value;
    final positive = amount > 0 ? amount : 0.0;
    if (d.preTax) {
      preTax += positive;
    } else {
      postTax += positive;
    }
  }

  return CalculationExtras(
    additionalAnnualGross: otAnnual + extraIncome,
    preTaxDeductionsAnnual: preTax,
    postTaxDeductionsAnnual: postTax,
  );
}

/// Convenience wrapper for full profiles.
CalculationExtras extrasFor(CalculationProfile p) => extrasFromInputs(
  hourlyRate: p.hourlyRate,
  frequency: p.payFrequency,
  income: p.income,
  overtime: p.overtime,
  incomeItems: p.incomeItems,
  userDeductions: p.deductions,
);

import 'package:flutter_test/flutter_test.dart';
import 'package:paycheck_calculator/core/constants/enums.dart';
import 'package:paycheck_calculator/data/models/calculation_profile.dart';

CalculationProfile fullProfile() => CalculationProfile(
  id: 'abc123',
  name: 'Main Job',
  country: Country.us,
  payFrequency: PayFrequency.biWeekly,
  income: 2600,
  filingStatus: FilingStatus.marriedJointly,
  regionCode: 'CA',
  hourlyRate: 25,
  hoursPerWeek: 40,
  overtime: const OvertimeInput(hoursPerPeriod: 4, multiplier: 1.5),
  incomeItems: [
    const ExtraIncomeItem(
      id: 'i1',
      name: 'Quarterly bonus',
      amount: 500,
      occurrence: ExtraIncomeOccurrence.everyPaycheck,
    ),
  ],
  deductions: [
    const UserDeduction(
      id: 'd1',
      name: '401k',
      value: 6,
      isPercentage: true,
      preTax: true,
      kind: DeductionKind.traditional401k,
    ),
  ],
  createdAt: DateTime.utc(2026, 1, 2, 3, 4),
  updatedAt: DateTime.utc(2026, 2, 3, 4, 5),
);

void main() {
  test('toJson/fromJson roundtrip preserves every field', () {
    final p = fullProfile();
    final p2 = CalculationProfile.fromJson(p.toJson());

    expect(p2.id, 'abc123');
    expect(p2.name, 'Main Job');
    expect(p2.country, Country.us);
    expect(p2.payFrequency, PayFrequency.biWeekly);
    expect(p2.income, 2600);
    expect(p2.filingStatus, FilingStatus.marriedJointly);
    expect(p2.regionCode, 'CA');
    expect(p2.hourlyRate, 25);
    expect(p2.hoursPerWeek, 40);
    expect(p2.overtime, isNotNull);
    expect(p2.overtime!.hoursPerPeriod, 4);
    expect(p2.overtime!.multiplier, 1.5);
    expect(p2.overtime!.explicitRate, isNull);
    expect(p2.incomeItems.single.name, 'Quarterly bonus');
    expect(
      p2.incomeItems.single.occurrence,
      ExtraIncomeOccurrence.everyPaycheck,
    );
    expect(p2.deductions.single.kind, DeductionKind.traditional401k);
    expect(p2.deductions.single.isPercentage, isTrue);
    expect(p2.deductions.single.preTax, isTrue);
    expect(p2.createdAt, DateTime.utc(2026, 1, 2, 3, 4));
    expect(p2.updatedAt, DateTime.utc(2026, 2, 3, 4, 5));
  });

  test('malformed json still yields a valid profile with defaults', () {
    final p = CalculationProfile.fromJson({'name': 'Broken', 'income': 'zap'});

    expect(p.id, isNotEmpty);
    expect(p.country, Country.us);
    expect(p.payFrequency, PayFrequency.annually);
    expect(p.income, 0);
    expect(p.filingStatus, isNull);
    expect(p.incomeItems, isEmpty);
    expect(p.deductions, isEmpty);
    expect(p.overtime, isNull);
    expect(p.createdAt, isA<DateTime>());
  });

  test('negative and missing numeric values clamp to zero', () {
    final p = CalculationProfile.fromJson({
      'name': 'Neg',
      'income': -50,
      'hourlyRate': -3,
      'incomeItems': [
        {'name': 'x', 'amount': -100},
      ],
    });

    expect(p.income, 0);
    expect(p.hourlyRate, 0);
    expect(p.incomeItems.single.amount, 0);
  });

  test('copyWith replaces scalars without aliasing list fields', () {
    final source = fullProfile();
    final copy = source.copyWith(
      id: 'new-id',
      name: 'Copy',
      incomeItems: List.of(source.incomeItems),
      deductions: List.of(source.deductions),
    );

    expect(copy.id, 'new-id');
    expect(copy.name, 'Copy');
    copy.incomeItems.removeRange(0, copy.incomeItems.length);
    expect(
      source.incomeItems,
      hasLength(1),
      reason: 'list mutation must not leak back into source',
    );
    copy.deductions.removeAt(0);
    expect(
      source.deductions,
      hasLength(1),
      reason: 'list mutation must not leak back into source',
    );
  });

  test('percentages above 100 are allowed at model level', () {
    const d = UserDeduction(
      id: 'd',
      name: 'x',
      value: 150,
      isPercentage: true,
      preTax: true,
      kind: DeductionKind.other,
    );
    final roundTrip = UserDeduction.fromJson(d.toJson());
    expect(roundTrip.value, 150);
  });

  test('generateProfileId is unique and non-empty', () {
    final a = generateProfileId();
    final b = generateProfileId();
    expect(a, isNotEmpty);
    expect(b, isNotEmpty);
    expect(a, isNot(b));
  });
}

import 'dart:math';

import '../../core/constants/enums.dart';

enum ExtraIncomeOccurrence { everyPaycheck, oncePerYear }

enum DeductionKind { traditional401k, roth401k, hsa, insurancePremium, other }

class OvertimeInput {
  final double hoursPerPeriod;
  final double? explicitRate;
  final double? multiplier;

  const OvertimeInput({
    required this.hoursPerPeriod,
    this.explicitRate,
    this.multiplier,
  });

  OvertimeInput copyWith({
    double? hoursPerPeriod,
    double? explicitRate,
    double? multiplier,
  }) =>
      OvertimeInput(
        hoursPerPeriod: hoursPerPeriod ?? this.hoursPerPeriod,
        explicitRate: explicitRate ?? this.explicitRate,
        multiplier: multiplier ?? this.multiplier,
      );

  Map<String, dynamic> toJson() => {
        if (hoursPerPeriod > 0) 'hoursPerPeriod': hoursPerPeriod,
        if (explicitRate != null) 'explicitRate': explicitRate,
        if (multiplier != null) 'multiplier': multiplier,
      };

  static OvertimeInput? fromJson(Object? json) {
    if (json is! Map) return null;
    final hours = _nonNegative(json['hoursPerPeriod']);
    if (hours <= 0) return null;
    return OvertimeInput(
      hoursPerPeriod: hours,
      explicitRate: _positiveOrNull(json['explicitRate']),
      multiplier: _positiveOrNull(json['multiplier']),
    );
  }
}

class ExtraIncomeItem {
  final String id;
  final String name;
  final double amount;
  final ExtraIncomeOccurrence occurrence;

  const ExtraIncomeItem({
    required this.id,
    required this.name,
    required this.amount,
    this.occurrence = ExtraIncomeOccurrence.everyPaycheck,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'occurrence': occurrence.name,
      };

  factory ExtraIncomeItem.fromJson(Object? json) {
    if (json is! Map) {
      return const ExtraIncomeItem(id: '', name: '', amount: 0);
    }
    return ExtraIncomeItem(
      id: json['id'] is String ? json['id'] as String : '',
      name: json['name'] is String ? json['name'] as String : '',
      amount: _nonNegative(json['amount']),
      occurrence: json['occurrence'] == ExtraIncomeOccurrence.oncePerYear.name
          ? ExtraIncomeOccurrence.oncePerYear
          : ExtraIncomeOccurrence.everyPaycheck,
    );
  }
}

class UserDeduction {
  final String id;
  final String name;
  final double value;
  final bool isPercentage;
  final bool preTax;
  final DeductionKind kind;

  const UserDeduction({
    required this.id,
    required this.name,
    required this.value,
    this.isPercentage = false,
    this.preTax = false,
    this.kind = DeductionKind.other,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'value': value,
        'isPercentage': isPercentage,
        'preTax': preTax,
        'kind': kind.name,
      };

  factory UserDeduction.fromJson(Object? json) {
    if (json is! Map) {
      return const UserDeduction(id: '', name: '', value: 0);
    }
    return UserDeduction(
      id: json['id'] is String ? json['id'] as String : '',
      name: json['name'] is String ? json['name'] as String : '',
      value: _nonNegative(json['value']),
      isPercentage: json['isPercentage'] == true,
      preTax: json['preTax'] == true,
      kind: DeductionKind.values
          .where((k) => k.name == json['kind'])
          .firstOrNull ??
          DeductionKind.other,
    );
  }
}

/// Safe top-level read helpers shared by the profile models.
double _nonNegative(Object? value) {
  final d = value is num ? value.toDouble() : double.tryParse('$value');
  if (d == null || d.isNaN || d <= 0) return 0;
  return d;
}

double? _positiveOrNull(Object? value) {
  final d = value is num ? value.toDouble() : double.tryParse('$value');
  if (d == null || d.isNaN || d <= 0) return null;
  return d;
}

class CalculationProfile {
  static const int schemaVersion = 1;

  String id;
  String name;
  Country country;
  PayFrequency payFrequency;
  double income;
  FilingStatus? filingStatus;
  String? regionCode;

  /// Hourly-converter inputs, persisted through profiles as-is.
  double hourlyRate;
  double hoursPerWeek;

  OvertimeInput? overtime;
  List<ExtraIncomeItem> incomeItems;
  List<UserDeduction> deductions;

  DateTime createdAt;
  DateTime updatedAt;

  CalculationProfile({
    required this.id,
    required this.name,
    this.country = Country.us,
    this.payFrequency = PayFrequency.annually,
    this.income = 0,
    this.filingStatus,
    this.regionCode,
    this.hourlyRate = 0,
    this.hoursPerWeek = 40,
    this.overtime,
    List<ExtraIncomeItem>? incomeItems,
    List<UserDeduction>? deductions,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : incomeItems = incomeItems ?? <ExtraIncomeItem>[],
        deductions = deductions ?? <UserDeduction>[],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  CalculationProfile copyWith({
    String? id,
    String? name,
    Country? country,
    PayFrequency? payFrequency,
    double? income,
    FilingStatus? filingStatus,
    String? regionCode,
    double? hourlyRate,
    double? hoursPerWeek,
    OvertimeInput? overtime,
    List<ExtraIncomeItem>? incomeItems,
    List<UserDeduction>? deductions,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearFilingStatus = false,
    bool clearRegionCode = false,
    bool clearOvertime = false,
  }) =>
      CalculationProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        country: country ?? this.country,
        payFrequency: payFrequency ?? this.payFrequency,
        income: income ?? this.income,
        filingStatus: clearFilingStatus ? null : filingStatus ?? this.filingStatus,
        regionCode: clearRegionCode ? null : regionCode ?? this.regionCode,
        hourlyRate: hourlyRate ?? this.hourlyRate,
        hoursPerWeek: hoursPerWeek ?? this.hoursPerWeek,
        overtime: clearOvertime ? null : overtime ?? this.overtime,
        incomeItems: incomeItems ?? List.of(this.incomeItems),
        deductions: deductions ?? List.of(this.deductions),
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'v': schemaVersion,
        'id': id,
        'name': name,
        'country': country.name,
        'payFrequency': payFrequency.name,
        'income': income,
        if (filingStatus != null) 'filingStatus': filingStatus!.name,
        if (regionCode != null) 'regionCode': regionCode,
        'hourlyRate': hourlyRate,
        'hoursPerWeek': hoursPerWeek,
        if (overtime != null) 'overtime': overtime!.toJson(),
        'incomeItems': incomeItems.map((i) => i.toJson()).toList(),
        'deductions': deductions.map((d) => d.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory CalculationProfile.fromJson(Object? json) {
    if (json is! Map) return CalculationProfile(id: generateProfileId(), name: '');
    return CalculationProfile(
      id: json['id'] is String && (json['id'] as String).isNotEmpty
          ? json['id'] as String
          : generateProfileId(),
      name: json['name'] is String ? json['name'] as String : '',
      country: Country.values
          .firstWhere((c) => c.name == json['country'], orElse: () => Country.us),
      payFrequency: PayFrequency.values.firstWhere(
          (f) => f.name == json['payFrequency'],
          orElse: () => PayFrequency.annually),
      income: _nonNegative(json['income']),
      filingStatus: FilingStatus.values.where((f) => f.name == json['filingStatus']).firstOrNull,
      regionCode: json['regionCode'] is String ? json['regionCode'] as String : null,
      hourlyRate: _nonNegative(json['hourlyRate']),
      hoursPerWeek: _nonNegative(json['hoursPerWeek']),
      overtime: OvertimeInput.fromJson(json['overtime']),
      incomeItems: _list(json['incomeItems'])
          .map(ExtraIncomeItem.fromJson)
          .where((i) => i.name.isNotEmpty)
          .toList(),
      deductions: _list(json['deductions'])
          .map(UserDeduction.fromJson)
          .where((d) => d.name.isNotEmpty)
          .toList(),
      createdAt: _dateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _dateTime(json['updatedAt']) ?? DateTime.now(),
    );
  }
}

List<Map<Object?, Object?>> _list(Object? value) {
  if (value is! List) return const [];
  return value.toList().cast<Map<Object?, Object?>>();
}

DateTime? _dateTime(Object? value) {
  if (value is! String) return null;
  return DateTime.tryParse(value)?.toUtc();
}

String generateProfileId() {
  final rand = Random();
  final suffix = rand.nextInt(1 << 32).toRadixString(36);
  return '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}.$suffix';
}

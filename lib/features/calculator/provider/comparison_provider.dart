import 'package:flutter/foundation.dart';

import '../../../../core/constants/enums.dart';
import '../../../../data/models/calculation_profile.dart';
import '../../../../data/models/region_tax.dart';
import '../../../../domain/calculators/task_calculator.dart';
import '../../../../domain/entities/paycheck_result.dart';
import '../../../../domain/usecases/pay_periods.dart';
import '../../../../domain/usecases/profile_inputs.dart';
import '../../../../domain/usecases/tax_calculator_factory.dart';
import '../../../../domain/usecases/tax_data_loader.dart';

/// Computes a saved profile's engine result via the existing engine only.
/// Shared by the comparison table and the saved-calculations screen.
Future<PaycheckResult> calculateProfileResult(
  CalculationProfile profile,
) async {
  final calculator = await TaxCalculatorFactory.get(profile.country);
  final region = await _regionFor(profile);
  return calculator.calculate(
    income: profile.income,
    frequency: profile.payFrequency,
    filingStatus: profile.filingStatus,
    region: region,
    extras: extrasFor(profile),
  );
}

Future<RegionTax?> _regionFor(CalculationProfile profile) async {
  final config = await TaxDataLoader.load(profile.country);
  if (config.regions == null) return null;
  for (final r in config.regions!.items) {
    if (r.code == profile.regionCode) return r;
  }
  return null;
}

/// One per-profile engine result — pure data, nothing cached or mutated.
class ComparisonRow {
  final CalculationProfile profile;
  final RegionTax? region;
  final PaycheckResult result;
  final int periodsInYear;

  const ComparisonRow({
    required this.profile,
    required this.region,
    required this.result,
    required this.periodsInYear,
  });
}

/// Orchestrates saved-profile comparisons. Read-only by contract: computing
/// rows never touches [ProfileProvider] state or the working calculator.
class ComparisonProvider extends ChangeNotifier {
  /// Reasonable maximum on a narrow mobile display.
  static const int maxSelections = 4;

  final List<String> selectedIds = [];

  int get selectionCount => selectedIds.length;

  void toggle(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else if (selectedIds.length < maxSelections) {
      selectedIds.add(id);
    }
    notifyListeners();
  }

  void remove(String id) {
    selectedIds.remove(id);
    notifyListeners();
  }

  void clear() {
    selectedIds.clear();
    notifyListeners();
  }

  bool isSelected(String id) => selectedIds.contains(id);

  /// Resolves saved profiles → engine results via the existing engine only.
  Future<List<ComparisonRow>> computeRows(
    List<CalculationProfile> allProfiles,
  ) async {
    final rows = <ComparisonRow>[];
    final cache = <Country, Future<TaxCalculator>>{};

    for (final id in selectedIds) {
      final profile = allProfiles.where((p) => p.id == id).firstOrNull;
      if (profile == null) continue; // deleted mid-session: skip safely

      final calculator = await cache.putIfAbsent(
        profile.country,
        () => TaxCalculatorFactory.get(profile.country),
      );
      rows.add(await _rowFor(profile, calculator));
    }
    return rows;
  }

  Future<ComparisonRow> _rowFor(
    CalculationProfile profile,
    TaxCalculator calculator,
  ) async {
    final region = await _regionFor(profile);
    final result = calculator.calculate(
      income: profile.income,
      frequency: profile.payFrequency,
      filingStatus: profile.filingStatus,
      region: region,
      extras: extrasFor(profile),
    );
    return ComparisonRow(
      profile: profile,
      region: region,
      result: result,
      periodsInYear: periodsPerYear(profile.payFrequency),
    );
  }
}

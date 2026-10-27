import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../../../data/models/calculation_profile.dart';
import 'calculator_provider.dart';

/// Owns saved calculation profiles (Hive) and the identity of the profile
/// whose inputs currently drive [CalculatorProvider].
///
/// Explicit-save model: activating a profile copies its inputs into the
/// working calculator; further edits stay in the working state and are
/// persisted only via [saveToActive] / [saveCurrentAs]. A broadcast autosave
/// would silently rewrite the active profile from unrelated edits.
///
/// Persistence ordering: every mutating method awaits the Hive write before
/// updating in-memory state, so a reported success is always durable.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this.calculator);

  final CalculatorProvider calculator;

  bool isLoading = false;
  List<CalculationProfile> profiles = <CalculationProfile>[];
  String? activeProfileId;

  Box<Map>? _profilesBox;
  Box? _stateBox;

  CalculationProfile? get activeProfile {
    final id = activeProfileId;
    if (id == null) return null;
    for (final p in profiles) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> load({Box<Map>? profilesBox, Box? stateBox}) async {
    isLoading = true;
    notifyListeners();

    try {
      _profilesBox = profilesBox ?? _profilesBox ?? await LocalStorageService.openProfilesBox();
      _stateBox = stateBox ?? _stateBox ?? await LocalStorageService.openStateBox();

      final loaded = <CalculationProfile>[];
      for (final value in _profilesBox!.values) {
        try {
          final profile = CalculationProfile.fromJson(value);
          // entries without id/name are unusable ghosts — skip, keep others
          if (profile.id.isEmpty || profile.name.trim().isEmpty) continue;
          loaded.add(profile);
        } catch (_) {
          // malformed entry: skip it, preserve the rest
        }
      }
      profiles = loaded;

      final storedId = _stateBox!.get(LocalStorageService.activeProfileKey);
      activeProfileId = storedId is String && loaded.any((p) => p.id == storedId)
          ? storedId
          : null;

      final active = activeProfile;
      if (active != null) {
        await _applyToCalculator(active);
      }
    } catch (e) {
      debugPrint('Profile load failed, keeping in-memory state: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _applyToCalculator(CalculationProfile profile) async {
    await calculator.applyProfile(profile);
  }

  Future<String> saveCurrentAs(String name) async {
    final profile = calculator.snapshotToProfile(name: name);
    final box = _profilesBox;
    final state = _stateBox;
    if (box == null || state == null) {
      throw StateError('ProfileProvider.load() must run before saving');
    }

    await box.put(profile.id, profile.toJson());
    await state.put(LocalStorageService.activeProfileKey, profile.id);

    profiles = [...profiles, profile];
    activeProfileId = profile.id;
    notifyListeners();
    return profile.id;
  }

  /// True when the working inputs differ from the active profile snapshot —
  /// a visible "Save changes" affordance should be offered to the user.
  bool get hasUnsavedChanges {
    final active = activeProfile;
    if (active == null) return false;
    final snapshot = _workingSnapshotOf(active);
    final a = active.toJson();
    final b = snapshot.toJson();
    for (final k in const [
      'v', 'id', 'name', 'country', 'payFrequency', 'income',
      'filingStatus', 'regionCode', 'hourlyRate', 'hoursPerWeek',
      'createdAt', 'updatedAt',
    ]) {
      if (a[k] != b[k]) return true;
    }
    // Lists: distinct empty instances never compare by identity — use JSON.
    return jsonEncode(a['incomeItems']) != jsonEncode(b['incomeItems']) ||
        jsonEncode(a['deductions']) != jsonEncode(b['deductions']);
  }

  CalculationProfile _workingSnapshotOf(CalculationProfile active) {
    final snapshot = calculator.snapshotToProfile(
      id: active.id,
      name: active.name,
    )
      ..createdAt = active.createdAt
      ..updatedAt = active.updatedAt; // timestamps excluded from the comparison
    return snapshot;
  }

  /// Persists the current working inputs into the active profile by ID.
  /// Intentionally explicit — never flips on data loss silently.
  Future<void> saveToActive() async {
    final box = _profilesBox;
    final active = activeProfile;
    if (box == null || active == null) return;

    final snapshot = _workingSnapshotOf(active)
      ..updatedAt = DateTime.now();

    try {
      await box.put(active.id, snapshot.toJson());
    } catch (e) {
      debugPrint('Save to active profile failed: $e');
      return;
    }

    final index = profiles.indexWhere((p) => p.id == active.id);
    if (index >= 0 && index < profiles.length) {
      profiles = [...profiles]..[index] = snapshot;
      notifyListeners();
    }
  }

  Future<void> rename(String id, String name) async {
    final box = _profilesBox;
    final target = _byIdOrNull(id);
    if (box == null || target == null) return;

    final renamed = target.copyWith(name: name);
    await box.put(id, renamed.toJson());

    profiles = [
      for (final p in profiles) p.id == id ? renamed : p,
    ];
    notifyListeners();
  }

  Future<CalculationProfile> duplicate(String id) async {
    final box = _profilesBox;
    final target = _byIdOrNull(id);
    if (box == null || target == null) {
      throw StateError('Cannot duplicate missing profile $id');
    }

    final copy = CalculationProfile(
      id: generateProfileId(),
      name: '${target.name} (copy)',
      country: target.country,
      payFrequency: target.payFrequency,
      income: target.income,
      filingStatus: target.filingStatus,
      regionCode: target.regionCode,
      hourlyRate: target.hourlyRate,
      hoursPerWeek: target.hoursPerWeek,
      overtime: target.overtime,
      incomeItems: List.of(target.incomeItems),
      deductions: List.of(target.deductions),
    );

    await box.put(copy.id, copy.toJson());
    profiles = [...profiles, copy];
    notifyListeners();
    return copy;
  }

  Future<void> delete(String id) async {
    final box = _profilesBox;
    final state = _stateBox;
    if (box == null || state == null) return;

    await box.delete(id);
    profiles = [for (final p in profiles) if (p.id != id) p];

    if (activeProfileId == id) {
      final next = profiles.isNotEmpty ? profiles.first : null;
      if (next != null) {
        await _applyToCalculator(next);
      }
      activeProfileId = next?.id;
      await state.put(LocalStorageService.activeProfileKey, next?.id);
    }
    notifyListeners();
  }

  Future<void> activate(String id) async {
    if (id == activeProfileId) return;
    final target = _byIdOrNull(id);
    if (target == null) return;

    await _applyToCalculator(target);

    activeProfileId = id;
    await _stateBox?.put(LocalStorageService.activeProfileKey, id);
    notifyListeners();
  }

  CalculationProfile? _byIdOrNull(String id) {
    for (final p in profiles) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

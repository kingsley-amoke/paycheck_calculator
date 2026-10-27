import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paycheck_calculator/core/services/local_storage_service.dart';
import 'package:paycheck_calculator/data/models/calculation_profile.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:paycheck_calculator/features/calculator/provider/profile_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('profile_test');
    Hive.init(tmp.path);
  });

  tearDown(() async {
    await Hive.close();
    tmp.deleteSync(recursive: true);
  });

  Future<(Box<Map>, Box)> boxes() async {
    final profiles =
        await Hive.openBox<Map>(LocalStorageService.profilesBoxName);
    final state = await Hive.openBox(LocalStorageService.stateBoxName);
    return (profiles, state);
  }

  test('saveCurrentAs persists and a fresh provider sees it (restart survival)',
      () async {
    final (profiles, state) = await boxes();
    final p1 = ProfileProvider(CalculatorProvider());
    await p1.load(profilesBox: profiles, stateBox: state);

    final id = await p1.saveCurrentAs('Main Job');
    expect(id, isNotEmpty);
    expect(p1.profiles, hasLength(1));
    expect(p1.activeProfileId, id);

    // "restart": fresh provider instance over the same boxes
    final p2 = ProfileProvider(CalculatorProvider());
    await p2.load(profilesBox: profiles, stateBox: state);
    expect(p2.profiles, hasLength(1));
    expect(p2.profiles.first.name, 'Main Job');
    expect(p2.activeProfileId, id);
  });

  test('rename persists', () async {
    final (profiles, state) = await boxes();
    final p = ProfileProvider(CalculatorProvider());
    await p.load(profilesBox: profiles, stateBox: state);
    final id = await p.saveCurrentAs('Old');

    await p.rename(id, 'New Job');
    final p2 = ProfileProvider(CalculatorProvider());
    await p2.load(profilesBox: profiles, stateBox: state);
    expect(p2.profiles.single.name, 'New Job');
  });

  test('duplicate gets a new id and deep-copied lists', () async {
    final (profiles, state) = await boxes();
    final p = ProfileProvider(CalculatorProvider());
    await p.load(profilesBox: profiles, stateBox: state);
    final id = await p.saveCurrentAs('Seed');

    final copy = await p.duplicate(id);
    final original = p.profiles.firstWhere((x) => x.id == id);

    expect(copy.id, isNot(id));
    expect(copy.name, 'Seed (copy)');
    expect(p.profiles, hasLength(2));
    expect(identical(copy.incomeItems, original.incomeItems), isFalse);

    copy.incomeItems.add(const ExtraIncomeItem(
        id: 'i1', name: 'Bonus', amount: 100));
    expect(original.incomeItems, isEmpty,
        reason: 'list mutation must not leak into the original');

    // duplicated profile is persisted too
    final fresh = ProfileProvider(CalculatorProvider());
    await fresh.load(profilesBox: profiles, stateBox: state);
    expect(fresh.profiles, hasLength(2));
  });

  test('activate switches working inputs and persists, snapshot B intact',
      () async {
    final (profiles, state) = await boxes();
    final first = ProfileProvider(CalculatorProvider());
    await first.load(profilesBox: profiles, stateBox: state);

    first.calculator.setIncome(75000);
    final idA = await first.saveCurrentAs('A');
    first.calculator.setIncome(100000);
    final idB = await first.saveCurrentAs('B');
    expect(first.activeProfileId, idB);
    expect(idA, isNot(idB));

    final second = ProfileProvider(CalculatorProvider());
    await second.load(profilesBox: profiles, stateBox: state);
    await second.activate(idA);

    expect(second.activeProfileId, idA);
    expect(second.calculator.income, closeTo(75000, 0.01),
        reason: 'A was captured at default inputs');
    expect(second.activeProfile!.name, 'A');
    expect(state.get(LocalStorageService.activeProfileKey), idA);
    expect(
      CalculationProfile.fromJson(await profiles.get(idB)).income,
      closeTo(100000, 0.01),
      reason: 'activate(A) must not overwrite snapshot B',
    );
  });

  test('deleting the active profile activates the first remaining', () async {
    final (profiles, state) = await boxes();
    final p = ProfileProvider(CalculatorProvider());
    await p.load(profilesBox: profiles, stateBox: state);

    p.calculator.setIncome(75000);
    final idA = await p.saveCurrentAs('A');
    p.calculator.setIncome(100000);
    final idB = await p.saveCurrentAs('B');
    expect(p.activeProfileId, idB);

    await p.delete(idB);
    expect(p.activeProfileId, idA);
    expect(state.get(LocalStorageService.activeProfileKey), idA);
    expect(p.profiles.single.id, idA);
  });

  test('deleting the last profile clears the active id, calculator untouched',
      () async {
    final (profiles, state) = await boxes();
    final calc = CalculatorProvider();
    final p = ProfileProvider(calc);
    await p.load(profilesBox: profiles, stateBox: state);

    calc.setIncome(95000);
    final id = await p.saveCurrentAs('Only');

    await p.delete(id);
    expect(p.activeProfileId, isNull);
    expect(state.get(LocalStorageService.activeProfileKey), isNull);
    expect(p.profiles, isEmpty);
    expect(await profiles.get(id), isNull, reason: 'box entry really removed');
    expect(calc.income, closeTo(95000, 0.01),
        reason: 'working calculation keeps its inputs after deleting all');
  });

  test('malformed stored entries are skipped without crashing', () async {
    final (profiles, state) = await boxes();
    await profiles
        .put('good', CalculationProfile(id: 'good', name: 'OK').toJson());
    // entry without id/name: unusable, must be skipped not turned into a ghost
    await profiles.put('garbage', {'income': 'not-a-number'});
    await profiles.put('garbage2', {
      'incomeItems': 5,
      'income': 'zap',
    });

    final p = ProfileProvider(CalculatorProvider());
    await p.load(profilesBox: profiles, stateBox: state);

    expect(p.profiles.map((x) => x.id), ['good']);
  });

  test('empty boxes load to an empty provider', () async {
    final (profiles, state) = await boxes();
    final p = ProfileProvider(CalculatorProvider());
    await p.load(profilesBox: profiles, stateBox: state);
    expect(p.profiles, isEmpty);
    expect(p.activeProfileId, isNull);
  });

  test('saveToActive stores edits into the active profile only', () async {
    final (profiles, state) = await boxes();
    final calc = CalculatorProvider();
    final p = ProfileProvider(calc);
    await p.load(profilesBox: profiles, stateBox: state);

    calc.setIncome(75000);
    final idA = await p.saveCurrentAs('A');
    calc.setIncome(100000);
    final idB = await p.saveCurrentAs('B');
    expect(p.activeProfileId, idB);

    // further edit is NOT persisted implicitly
    calc.setIncome(120000);
    await Future<void>.delayed(Duration.zero);
    expect(
      CalculationProfile.fromJson(await profiles.get(idB)).income,
      closeTo(100000, 0.01),
      reason: 'working edits must not rewrite the profile silently',
    );
    expect(p.hasUnsavedChanges, isTrue);

    // explicit save lands in the active profile only
    await p.saveToActive();
    expect(p.hasUnsavedChanges, isFalse);
    expect(
      CalculationProfile.fromJson(await profiles.get(idB)).income,
      closeTo(120000, 0.01),
    );
    expect(
      CalculationProfile.fromJson(await profiles.get(idA)).income,
      closeTo(75000, 0.01),
      reason: 'edit must not unintentionally modify another profile',
    );
  });

  test('dispose leaves the provider inert without throwing', () async {
    final (profiles, state) = await boxes();
    final calc = CalculatorProvider();
    final p = ProfileProvider(calc);
    await p.load(profilesBox: profiles, stateBox: state);
    calc.setIncome(95000);
    final id = await p.saveCurrentAs('Disposed');

    p.dispose();
    calc.setIncome(111);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final parsed = CalculationProfile.fromJson(await profiles.get(id));
    expect(parsed.income, closeTo(95000, 0.01),
        reason: 'no persistence may happen after dispose');
  });

  test('activate does not echo pre-load state into the profile', () async {
    final (profiles, state) = await boxes();
    final first = ProfileProvider(CalculatorProvider());
    await first.load(profilesBox: profiles, stateBox: state);
    first.calculator.setIncome(100000);
    final idB = await first.saveCurrentAs('B');

    // fresh provider whose calculator is at defaults; loading B must not
    // overwrite any persisted pre-load state
    final second = ProfileProvider(CalculatorProvider());
    await second.load(profilesBox: profiles, stateBox: state);
    await second.activate(idB);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final parsed = CalculationProfile.fromJson(await profiles.get(idB));
    expect(parsed.income, closeTo(100000, 0.01),
        reason: 'activate must not clobber the profile with pre-load inputs');
    expect(parsed.name, 'B');
  });
}

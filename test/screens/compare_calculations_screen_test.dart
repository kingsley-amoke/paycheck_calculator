import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paycheck_calculator/features/calculator/presentation/screens/compare_calculations_screen.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:paycheck_calculator/features/calculator/provider/comparison_provider.dart';
import 'package:paycheck_calculator/features/calculator/provider/profile_provider.dart';
import 'package:provider/provider.dart';

/// In-memory persistence (FakeAsync cannot drive Hive file I/O).
class FakeBox<T> implements Box<T> {
  FakeBox();

  final Map<dynamic, T> data = {};

  @override
  Iterable<T> get values => data.values;

  @override
  T? get(dynamic key, {T? defaultValue}) => data[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, T value) async {
    data[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    data.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('FakeBox.${invocation.memberName}');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CalculatorProvider calc;
  late ProfileProvider profiles;
  late ComparisonProvider comparison;

  setUp(() async {
    calc = CalculatorProvider();
    await calc.init();
    profiles = ProfileProvider(calc)
      ..load(profilesBox: FakeBox<Map>(), stateBox: FakeBox());
    comparison = ComparisonProvider();
  });

  Widget host() => MultiProvider(
        providers: [
          ChangeNotifierProvider<CalculatorProvider>.value(value: calc),
          ChangeNotifierProvider<ProfileProvider>.value(value: profiles),
          ChangeNotifierProvider<ComparisonProvider>.value(value: comparison),
        ],
        child: const MaterialApp(home: CompareCalculationsScreen()),
      );

  Future<void> drain(WidgetTester tester) async {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();
  }

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(host());
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await drain(tester);
  }

  testWidgets('selecting 2 profiles renders table with net pay winner banner',
      (tester) async {
    final idA = await profiles.saveCurrentAs('Base');
    calc.setIncome(120000);
    final idB = await profiles.saveCurrentAs('Raise');

    await pump(tester);

    await tester.tap(find.text('Base'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Raise'));
    await tester.pump();
    await drain(tester);
    await tester.pump();
    await drain(tester);
    await tester.pump();

    expect(find.text('Base'), findsWidgets);
    expect(find.text('Raise'), findsWidgets);
    expect(find.text('Estimated net pay'), findsOneWidget);
    expect(find.text('Higher net pay: Raise'), findsOneWidget,
        reason: 'engine net must pick the larger salary');
    expect(idA, isNot(idB));
  });

  testWidgets('clearing selection returns the hint state', (tester) async {
    await profiles.saveCurrentAs('Base');
    calc.setIncome(120000);
    await profiles.saveCurrentAs('Raise');

    await pump(tester);

    await tester.tap(find.text('Base'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Raise'));
    await tester.pump();
    await drain(tester);
    await tester.pump();
    await drain(tester);
    await tester.pump();
    expect(find.text('Estimated net pay'), findsOneWidget);

    // let the chip's delete-icon drawer animation finish
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump(const Duration(milliseconds: 150));
    await drain(tester);

    expect(find.text('Estimated net pay'), findsNothing);
    expect(find.text('Select at least two calculations'), findsOneWidget);
  });

  testWidgets('max 4 selections enforced locally', (tester) async {
    for (var i = 0; i < 5; i++) {
      await profiles.saveCurrentAs('P$i');
    }
    await pump(tester);

    await tester.tap(find.text('P0'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('P1'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('P2'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('P3'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('P4'));
    await tester.pump(const Duration(milliseconds: 150));
    await drain(tester);

    expect(comparison.selectedIds.length, 4);
  });

  testWidgets('deleting a selected profile mid-session does not crash',
      (tester) async {
    final idA = await profiles.saveCurrentAs('Base');
    calc.setIncome(1000);
    await profiles.saveCurrentAs('Raise');

    await pump(tester);

    await tester.tap(find.text('Base'));
    await tester.pump(const Duration(milliseconds: 150));
    await drain(tester);

    await profiles.delete(idA);
    await tester.pumpWidget(host()); // simulate rebuild after deletion
    await tester.pump(const Duration(milliseconds: 150));
    await drain(tester);

    expect(find.byType(CompareCalculationsScreen), findsOneWidget);
    expect(comparison.selectedIds.length, 1);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paycheck_calculator/features/calculator/presentation/screens/compare_calculations_screen.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:paycheck_calculator/features/calculator/provider/comparison_provider.dart';
import 'package:paycheck_calculator/features/calculator/provider/profile_provider.dart';
import 'package:provider/provider.dart';

class FakeBox<T> implements Box<T> {
  final Map<dynamic, T> data = {};
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('FakeBox.${invocation.memberName}');
  @override
  Iterable<T> get values => data.values;
  @override
  T? get(dynamic key, {T? defaultValue}) => data[key] ?? defaultValue;
  @override
  Future<void> put(dynamic key, T value) async => data[key] = value;
  @override
  Future<void> delete(dynamic key) async => data.remove(key);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('probe: dump texts after selecting two profiles', (tester) async {
    late CalculatorProvider calc;
    late ProfileProvider profiles;
    late ComparisonProvider comparison;
    await tester.runAsync(() async {
      calc = CalculatorProvider();
      await calc.init();
      profiles = ProfileProvider(calc)
        ..load(profilesBox: FakeBox(), stateBox: FakeBox());
      comparison = ComparisonProvider();
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await profiles.saveCurrentAs('Base');
    calc.setIncome(120000);
    await profiles.saveCurrentAs('Raise');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CalculatorProvider>.value(value: calc),
          ChangeNotifierProvider<ProfileProvider>.value(value: profiles),
          ChangeNotifierProvider<ComparisonProvider>.value(value: comparison),
        ],
        child: const MaterialApp(home: CompareCalculationsScreen()),
      ),
    );
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();

    await tester.tap(find.text('Base'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Raise'));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
    }

    debugPrint('SELECTED IDS: ${comparison.selectedIds}');
    debugPrint(
        'ENP_OFFSTAGE: ${tester.widgetList(find.text('Estimated net pay', skipOffstage: false)).length}');
    debugPrint('TABLE_OFFSTAGE: ${tester.widgetList(find.byType(Table, skipOffstage: false)).length}');
    debugPrint('ROW_OFFSTAGE: ${tester.widgetList(find.byType(Row, skipOffstage: false)).length}');
    final texts = tester
        .widgetList<Text>(find.byType(Text, skipOffstage: false))
        .map((t) => t.data ?? t.textSpan?.toPlainText())
        .toSet();
    debugPrint('TEXTS: ${texts.join(' | ')}');
  });
}

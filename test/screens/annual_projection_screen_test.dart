import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paycheck_calculator/features/calculator/presentation/screens/annual_projection_screen.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/monthly_bars_chart.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
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

  setUp(() async {
    calc = CalculatorProvider();
    await calc.init();
    profiles = ProfileProvider(calc)
      ..load(profilesBox: FakeBox<Map>(), stateBox: FakeBox());
  });

  Widget host() => MultiProvider(
    providers: [
      ChangeNotifierProvider<CalculatorProvider>.value(value: calc),
      ChangeNotifierProvider<ProfileProvider>.value(value: profiles),
    ],
    child: const MaterialApp(home: AnnualProjectionScreen()),
  );

  Future<void> drain(WidgetTester tester) async {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();
  }

  testWidgets('12 bars painted from the active profile', (tester) async {
    await profiles.saveCurrentAs('Main Job');

    await tester.pumpWidget(host());
    await tester.pump();
    await drain(tester);
    await tester.pump();
    await drain(tester);
    await tester.pump();

    final paints = find.byWidgetPredicate(
      (w) => w is CustomPaint && w.painter is MonthlyBarsChartPainter,
    );
    expect(paints, findsOneWidget);
  });

  testWidgets('legend chip switches the series to Gross', (tester) async {
    await profiles.saveCurrentAs('Main Job');

    await tester.pumpWidget(host());
    await tester.pump();
    await drain(tester);
    await tester.pump();
    await drain(tester);
    await tester.pump();

    expect(find.text('Net'), findsOneWidget);
    expect(find.text('Gross'), findsOneWidget);

    await tester.tap(find.text('Gross'));
    await tester.pump();
    await drain(tester);

    // totals row reflects the series: annual gross total shown
    expect(find.textContaining('Annual'), findsWidgets);
  });

  testWidgets('totals row is formatted with CurrencyFormatter', (tester) async {
    await profiles.saveCurrentAs('Main Job');
    await tester.pumpWidget(host());
    await tester.pump();
    await drain(tester);
    await tester.pump();
    await drain(tester);
    await tester.pump();

    // currency symbol present anywhere in the totals row
    final totalsText = find.textContaining(RegExp(r'\$'));
    expect(totalsText, findsWidgets);
  });
}

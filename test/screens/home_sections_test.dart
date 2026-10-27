import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/extra_income_section.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/overtime_section.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/save_profile_sheet.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/user_deductions_section.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:paycheck_calculator/features/calculator/provider/profile_provider.dart';
import 'package:provider/provider.dart';

/// Section widget tests. Persistence is faked in-memory: widget taps run in
/// FakeAsync, which cannot drive Hive's real file I/O (real-Hive persistence
/// is covered in profile_provider_test.dart).
class FakeBox<T> implements Box<T> {
  final Map<dynamic, T> data = {};

  FakeBox();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('FakeBox.${invocation.memberName}');
  }

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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(CalculatorProvider, ProfileProvider)> makeProviders(
    WidgetTester tester,
  ) async {
    final (calc, profiles) = (await tester.runAsync(() async {
      final calc = CalculatorProvider();
      await calc.init();
      final profiles = ProfileProvider(calc)
        ..load(profilesBox: FakeBox(), stateBox: FakeBox());
      return (calc, profiles);
    }))!;
    return (calc, profiles);
  }

  Future<void> pump2(
    WidgetTester tester,
    Widget child,
    CalculatorProvider calc,
    ProfileProvider profiles,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CalculatorProvider>.value(value: calc),
          ChangeNotifierProvider<ProfileProvider>.value(value: profiles),
        ],
        child: MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('add income item via bottom sheet updates paycheck result', (
    tester,
  ) async {
    final (calc, profiles) = await makeProviders(tester);
    await pump2(tester, const ExtraIncomeSection(), calc, profiles);
    final before = calc.result!.netIncome;

    await tester.tap(find.text('ADD'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Signing bonus');
    await tester.enterText(find.byType(TextField).last, '1000');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    // engine recalc futures resolve via real async: drain before asserts
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();

    expect(find.text('Signing bonus'), findsOneWidget);
    expect(calc.result!.netIncome, greaterThan(before));
  });

  testWidgets('remove income item drops it from the estimate', (tester) async {
    final (calc, profiles) = await makeProviders(tester);
    await pump2(tester, const ExtraIncomeSection(), calc, profiles);

    await tester.tap(find.text('ADD'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Tips');
    await tester.enterText(find.byType(TextField).last, '100');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    // engine recalc futures resolve via real async: drain before asserts
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();
    final inflated = calc.result!.netIncome;

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();

    expect(find.text('Tips'), findsNothing);
    expect(calc.result!.netIncome, lessThan(inflated));
  });

  testWidgets('user deductions group under pre-tax and post-tax headers', (
    tester,
  ) async {
    final (calc, profiles) = await makeProviders(tester);
    await pump2(tester, const UserDeductionsSection(), calc, profiles);
    final before = calc.result!.netIncome;

    // pre-tax 401k
    await tester.tap(find.text('ADD'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '401k');
    await tester.enterText(find.byType(TextField).last, '500');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    // engine recalc futures resolve via real async: drain before asserts
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();

    expect(find.text('401k'), findsOneWidget);
    expect(
      calc.result!.netIncome,
      lessThan(before),
      reason: 'pre-tax deduction applied',
    );

    // post-tax loan
    await tester.tap(find.text('ADD'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Loan');
    await tester.enterText(find.byType(TextField).last, '25');
    await tester.tap(find.text('Pre-tax', skipOffstage: false).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    // engine recalc futures resolve via real async: drain before asserts
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();

    expect(find.text('Loan'), findsOneWidget);
    expect(calc.userDeductions.where((d) => d.preTax).map((d) => d.name), [
      '401k',
    ]);
    expect(calc.userDeductions.where((d) => !d.preTax).map((d) => d.name), [
      'Loan',
    ]);
  });

  testWidgets('overtime sheet rejects empty hours input', (tester) async {
    final (calc, profiles) = await makeProviders(tester);
    await pump2(tester, const OvertimeSection(), calc, profiles);

    await tester.tap(find.text('ADD'));
    await tester.pumpAndSettle();

    // leave hours empty, press save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter hours worked'), findsOneWidget);
    expect(calc.overtimeHoursPerPeriod, 0);
  });

  testWidgets('overtime with hours and rate raises the estimate', (
    tester,
  ) async {
    final (calc, profiles) = await makeProviders(tester);
    await pump2(tester, const OvertimeSection(), calc, profiles);
    final before = calc.result!.netIncome;

    await tester.tap(find.text('ADD'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '5');
    await tester.enterText(find.byType(TextField).last, '50');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    // engine recalc futures resolve via real async: drain before asserts
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();

    expect(calc.overtimeHoursPerPeriod, 5);
    expect(calc.overtimeRate, 50);
    expect(calc.result!.netIncome, greaterThan(before));
  });

  testWidgets('save profile sheet creates a persisted profile', (tester) async {
    final (calc, profiles) = await makeProviders(tester);
    await pump2(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showSaveProfileSheet(context),
          child: const Text('open save sheet'),
        ),
      ),
      calc,
      profiles,
    );

    await tester.tap(find.text('open save sheet'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Main Job');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    // engine recalc futures resolve via real async: drain before asserts
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();

    expect(profiles.profiles, hasLength(1));
    expect(profiles.profiles.single.name, 'Main Job');
    expect(profiles.activeProfileId, profiles.profiles.single.id);
  });
}

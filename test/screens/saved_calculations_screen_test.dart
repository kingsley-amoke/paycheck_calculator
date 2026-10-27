import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paycheck_calculator/features/calculator/presentation/screens/saved_calculations_screen.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:paycheck_calculator/features/calculator/provider/profile_provider.dart';
import 'package:provider/provider.dart';

/// Persistence is faked in-memory here (FakeAsync cannot drive Hive file
/// I/O); durable persistence is covered by profile_provider_test.dart.
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

  /// Lets engine futures (asset-backed, real async) resolve, then one frame.
  Future<void> drain(WidgetTester tester) async {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();
  }

  Widget host() => MultiProvider(
    providers: [
      ChangeNotifierProvider<CalculatorProvider>.value(value: calc),
      ChangeNotifierProvider<ProfileProvider>.value(value: profiles),
    ],
    child: const MaterialApp(home: SavedCalculationsScreen()),
  );

  testWidgets('empty state offers to save a calculation', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await drain(tester);
    await drain(tester);

    expect(find.text('No saved calculations yet'), findsOneWidget);
    expect(find.text('Save your current calculation'), findsOneWidget);
  });

  testWidgets('cards render name, frequency and Active chip', (tester) async {
    await profiles.saveCurrentAs('Main Job');
    calc.setIncome(90000);
    await profiles.saveCurrentAs('New Offer');

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await drain(tester);
    await drain(tester);
    // real async: engine results for the cards
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();

    expect(find.text('Main Job'), findsOneWidget);
    expect(find.text('New Offer'), findsOneWidget);
    expect(find.textContaining('Annually ·'), findsWidgets);
    expect(
      find.text('Active'),
      findsOneWidget,
      reason: 'exactly one profile is active',
    );
  });

  testWidgets('overflow menu lists the five profile actions', (tester) async {
    await profiles.saveCurrentAs('Main Job');
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await drain(tester);
    await drain(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    for (final action in [
      'Open',
      'Activate',
      'Duplicate',
      'Rename',
      'Delete',
    ]) {
      expect(find.text(action), findsOneWidget, reason: action);
    }
  });

  testWidgets('rename updates the card', (tester) async {
    await profiles.saveCurrentAs('Main Job');
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await drain(tester);
    await drain(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Renamed Job');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Renamed Job'), findsOneWidget);
    expect(profiles.profiles.single.name, 'Renamed Job');
  });

  testWidgets('delete with confirmation removes the card', (tester) async {
    await profiles.saveCurrentAs('Gone Soon');
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await drain(tester);
    await drain(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.textContaining('cannot be undone'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('Gone Soon'), findsNothing);
    expect(profiles.profiles, isEmpty);
  });

  testWidgets('duplicate adds a copy card', (tester) async {
    await profiles.saveCurrentAs('Seed');
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await drain(tester);
    await drain(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplicate'));
    await tester.pumpAndSettle();

    expect(find.text('Seed (copy)'), findsOneWidget);
    expect(profiles.profiles, hasLength(2));
  });

  testWidgets('activate moves the Active chip', (tester) async {
    final idA = await profiles.saveCurrentAs('A');
    calc.setIncome(100000);
    await profiles.saveCurrentAs('B');
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await drain(tester);
    await drain(tester);
    expect(find.text('Active'), findsOneWidget);

    // open card A's overflow menu (cards render in Hive key order)
    await tester.tap(
      find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is ProfileCard && w.profile.name == 'A',
        ),
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Activate'));
    await tester.pumpAndSettle();
    await drain(tester);

    expect(profiles.activeProfileId, idA);
  });
}

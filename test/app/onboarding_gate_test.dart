import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paycheck_calculator/app/app.dart';
import 'package:paycheck_calculator/core/services/local_storage_service.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:paycheck_calculator/features/calculator/provider/comparison_provider.dart';
import 'package:paycheck_calculator/features/calculator/provider/profile_provider.dart';
import 'package:paycheck_calculator/features/settings/settings_provider.dart';
import 'package:paycheck_calculator/features/subscription/domain/subscription_status.dart';
import 'package:paycheck_calculator/features/paywall/paywall_scheduler.dart';
import 'package:paycheck_calculator/features/subscription/provider/subscription_provider.dart';
import 'package:paycheck_calculator/features/subscription/services/revenuecat_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../helpers/fake_stubs.dart';
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

class _StubRevenueCatService implements RevenueCatService {
  @override
  Future<MySubscriptionInfo> getSubscriptionStatus() async =>
      const MySubscriptionInfo(
        status: SubscriptionStatus.expired,
        isActive: false,
        isInTrial: false,
      );

  @override
  Future<CustomerInfo> restore() => throw UnimplementedError();

  @override
  Future<MySubscriptionInfo> init(String apiKey, String? userId) =>
      throw UnimplementedError();

  @override
  Future<PurchaseResult> purchasePackage(Package package) =>
      throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first launch (flag unset) starts with onboarding', (
    tester,
  ) async {
    // Onboarding pages are designed for phone-sized windows; the default
    // 800×600 test window overflows their fixed-height columns.
    tester.view.physicalSize = const Size(411, 880);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => SubscriptionProvider(_StubRevenueCatService()),
          ),
        ],
        child: const PaycheckApp(onboardingComplete: false),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // The Hook page copy from the onboarding flow.
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Calculate'), findsNothing);
  });

  testWidgets('returning user (flag set) lands in MainShell', (tester) async {
    final subscription = SubscriptionProvider(
      StubRevenueCatService.free(),
      reviewAccess: FakeReviewAccess(),
    );
    Hive.init('/tmp/opencode/hive_gate_test');
    // Pre-open the state box with a real I/O drain so MainShell's
    // idempotent write resolves synchronously afterwards.
    await tester.runAsync(() async {
      await LocalStorageService.openStateBox();
    });
    final calc = CalculatorProvider();
    final profiles = ProfileProvider(calc)
      ..load(profilesBox: FakeBox(), stateBox: FakeBox());
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider(),
          ),
          ChangeNotifierProvider<CalculatorProvider>.value(value: calc),
          ChangeNotifierProvider<ProfileProvider>.value(value: profiles),
          ChangeNotifierProvider<ComparisonProvider>(
            create: (_) => ComparisonProvider(),
          ),
          ChangeNotifierProvider<SubscriptionProvider>.value(
            value: subscription,
          ),
          ChangeNotifierProvider<PaywallScheduler>.value(
            value: PaywallScheduler(subscription),
          ),
        ],
        child: const PaycheckApp(onboardingComplete: true),
      ),
    );
    // HomeScreen calculator init runs async; drain before asserting.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // The onboarding-complete write uses real Hive I/O: drain it too.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();

    // The bottom navigation bar.
    expect(find.text('Projections'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);

    // The funnel behind the shell marked onboarding complete.
    expect(
      Hive.box(
        LocalStorageService.stateBoxName,
      ).get(LocalStorageService.onboardingCompleteKey),
      isTrue,
    );
  });
}

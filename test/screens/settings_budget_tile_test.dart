import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paycheck_calculator/core/config/expense_tracker_config.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:paycheck_calculator/features/settings/settings_provider.dart';
import 'package:paycheck_calculator/features/settings/settings_screen.dart';
import 'package:paycheck_calculator/features/subscription/provider/subscription_provider.dart';
import 'package:paycheck_calculator/features/subscription/domain/feature_access.dart';
import 'package:paycheck_calculator/features/subscription/domain/subscription_status.dart';
import 'package:paycheck_calculator/features/subscription/services/revenuecat_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';

class _StubRevenueCatService implements RevenueCatService {
  @override
  Future<MySubscriptionInfo> getSubscriptionStatus() async {
    return const MySubscriptionInfo(
      status: SubscriptionStatus.expired,
      isActive: false,
      isInTrial: false,
    );
  }

  @override
  Future<CustomerInfo> restore() => throw UnimplementedError();

  @override
  Future<MySubscriptionInfo> init(String apiKey, String? userId) =>
      throw UnimplementedError();

  @override
  Future<PurchaseResult> purchasePackage(Package package) =>
      throw UnimplementedError();
}

Widget host() => MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CalculatorProvider()),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
    ChangeNotifierProvider(
      create: (_) => SubscriptionProvider(_StubRevenueCatService()),
    ),
  ],
  child: const MaterialApp(home: SettingsScreen()),
);

void main() {
  test('FeatureAccess gates by limits without touching saved data', () {
    expect(FeatureAccess.canAddProfile(0, false), isTrue);
    expect(FeatureAccess.canAddProfile(1, false), isFalse);
    expect(FeatureAccess.canAddProfile(5, true), isTrue);
    expect(FeatureAccess.canCompare(false), isFalse);
    expect(FeatureAccess.canCompare(true), isTrue);
    expect(FeatureAccess.canProject(true), isTrue);
    expect(FeatureAccess.canAddItem(2, false), isFalse);
    expect(FeatureAccess.canAddItem(2, true), isTrue);
  });

  testWidgets(
    'budget tile shows fallback dialog when destination unconfigured',
    (tester) async {
      expect(
        ExpenseTrackerConfig.isConfigured,
        isFalse,
        reason: 'no destination is shipped in the codebase',
      );

      await tester.pumpWidget(host());
      await tester.pump();
      expect(find.text('Manage Your Budget'), findsOneWidget);

      await tester.tap(find.text('Manage Your Budget'));
      await tester.pump();

      expect(
        find.textContaining('Expense Tracker'),
        findsWidgets,
        reason: 'fallback explains the unconfigured destination',
      );
    },
  );
}

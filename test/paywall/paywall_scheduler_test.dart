import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paycheck_calculator/features/paywall/paywall_scheduler.dart';
import 'package:paycheck_calculator/features/subscription/domain/subscription_status.dart';
import 'package:paycheck_calculator/features/subscription/provider/subscription_provider.dart';
import 'package:paycheck_calculator/features/subscription/services/revenuecat_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../helpers/fake_stubs.dart';

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

class _FreeRevenueCat implements RevenueCatService {
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

class _ProRevenueCat implements RevenueCatService {
  @override
  Future<MySubscriptionInfo> getSubscriptionStatus() async =>
      const MySubscriptionInfo(
        status: SubscriptionStatus.active,
        isActive: true,
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

  SubscriptionProvider sub(RevenueCatService rc, {bool review = false}) =>
      SubscriptionProvider(rc, reviewAccess: FakeReviewAccess(enabled: review));

  test('free user: 4 completed calculations reach the threshold', () {
    final scheduler = PaywallScheduler(sub(_FreeRevenueCat()));

    expect(scheduler.shouldShowPaywall, isFalse);
    scheduler.onCalculationCompleted();
    scheduler.onCalculationCompleted();
    scheduler.onCalculationCompleted();
    expect(scheduler.shouldShowPaywall, isFalse);

    scheduler.onCalculationCompleted();
    expect(scheduler.shouldShowPaywall, isTrue);
  });

  test('subscriber never sees the paywall', () async {
    final subscription = sub(_ProRevenueCat());
    await subscription.refresh();
    final scheduler = PaywallScheduler(subscription);

    for (var i = 0; i < 6; i++) {
      scheduler.onCalculationCompleted();
    }
    expect(scheduler.shouldShowPaywall, isFalse);
  });

  test('showing the paywall resets and persists the count', () async {
    final box = FakeBox();
    final scheduler = PaywallScheduler(sub(_FreeRevenueCat()), stateBox: box);

    for (var i = 0; i < PaywallScheduler.calcThreshold; i++) {
      scheduler.onCalculationCompleted();
    }
    await Future<void>.delayed(Duration.zero);
    expect(box.get(PaywallScheduler.countKey), 4);

    scheduler.onPaywallShown();
    expect(scheduler.shouldShowPaywall, isFalse);
    await Future<void>.delayed(Duration.zero);
    expect(box.get(PaywallScheduler.countKey), 0);

    // After one more calculation cycle it pends again.
    scheduler.onCalculationCompleted();
    scheduler.onCalculationCompleted();
    scheduler.onCalculationCompleted();
    scheduler.onCalculationCompleted();
    expect(scheduler.shouldShowPaywall, isTrue);
  });

  test('count is restored from the persisted box', () async {
    final box = FakeBox();
    box.put(PaywallScheduler.countKey, 3);
    final scheduler = PaywallScheduler(sub(_FreeRevenueCat()), stateBox: box);

    scheduler.onCalculationCompleted();
    expect(scheduler.shouldShowPaywall, isTrue);
  });

  test('review-access override counts as premium', () {
    // SubscriptionProvider mocks ReviewAccessService internally; free stubs
    // plus remote-config default (off) keeps the free path exercised.
    final scheduler = PaywallScheduler(sub(_FreeRevenueCat()));
    expect(scheduler.isFreeUser, isTrue);
    expect(
      PaywallScheduler(sub(_ProRevenueCat(), review: true)).isFreeUser,
      isFalse,
    );
  });
}

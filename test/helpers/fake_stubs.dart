import 'package:hive/hive.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:paycheck_calculator/features/subscription/domain/subscription_status.dart';
import 'package:paycheck_calculator/features/subscription/services/revenuecat_service.dart';

/// Shared in-memory Hive box for widget/unit tests: FakeAsync cannot drive
/// Hive's real file I/O (real-Hive persistence is covered separately).
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

/// RevenueCat stand-in that returns a fixed subscription status without
/// touching the native SDK.
class StubRevenueCatService implements RevenueCatService {
  StubRevenueCatService(this._info);

  final MySubscriptionInfo _info;

  factory StubRevenueCatService.free() => StubRevenueCatService(
    const MySubscriptionInfo(
      status: SubscriptionStatus.expired,
      isActive: false,
      isInTrial: false,
    ),
  );

  factory StubRevenueCatService.premium() => StubRevenueCatService(
    const MySubscriptionInfo(
      status: SubscriptionStatus.active,
      isActive: true,
      isInTrial: false,
    ),
  );

  @override
  Future<MySubscriptionInfo> getSubscriptionStatus() async => _info;

  @override
  Future<CustomerInfo> restore() => throw UnimplementedError();

  @override
  Future<MySubscriptionInfo> init(String apiKey, String? userId) =>
      throw UnimplementedError();

  @override
  Future<PurchaseResult> purchasePackage(Package package) =>
      throw UnimplementedError();
}

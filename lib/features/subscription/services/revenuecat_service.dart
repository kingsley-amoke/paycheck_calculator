import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../domain/subscription_status.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;

  static const String entitlementId = "access";

  /// Initialize RevenueCat
  Future<void> init(String apiKey, String? userId) async {
    if (_isInitialized) return;
    try {
      await Purchases.configure(
        PurchasesConfiguration(apiKey)..appUserID = userId,
      );

      _isInitialized = true;

      if (kDebugMode) {
        print("✅ RevenueCat initialized");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ RevenueCat init error: $e");
      }
    }
  }

  Future<MySubscriptionInfo> getSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      final entitlement = customerInfo.entitlements.all['premium'];

      if (entitlement == null) {
        return const MySubscriptionInfo(
          status: SubscriptionStatus.expired,
          isActive: false,
          isInTrial: false,
        );
      }

      final isActive = entitlement.isActive;
      final isTrial = entitlement.periodType == PeriodType.trial;

      return MySubscriptionInfo(
        status: isActive
            ? (isTrial ? SubscriptionStatus.inTrial : SubscriptionStatus.active)
            : SubscriptionStatus.expired,
        isActive: isActive,
        isInTrial: isTrial,
        expirationDate: entitlement.expirationDate != null
            ? DateTime.parse(entitlement.expirationDate!)
            : null,
      );
    } catch (e) {
      return const MySubscriptionInfo(
        status: SubscriptionStatus.unknown,
        isActive: false,
        isInTrial: false,
      );
    }
  }

  Future<PurchaseResult> purchasePackage(Package package) async {
    final PurchaseParams params = PurchaseParams.package(package);

    return await Purchases.purchase(params);
  }

  Future<CustomerInfo> restore() async {
    return await Purchases.restorePurchases();
  }
}

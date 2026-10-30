import 'package:flutter/foundation.dart';
import 'package:paycheck_calculator/core/services/remote_config.dart';
import '../services/revenuecat_service.dart';
import '../domain/subscription_status.dart';

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionProvider(this._service, {ReviewAccessService? reviewAccess})
    : reviewAccess = reviewAccess ?? ReviewAccessService();

  // Lazily injectable so tests can stand in for Remote Config (no Firebase).
  final ReviewAccessService reviewAccess;
  final RevenueCatService _service;
  bool isLoading = true;

  MySubscriptionInfo _info = const MySubscriptionInfo(
    status: SubscriptionStatus.unknown,
    isActive: false,
    isInTrial: false,
  );

  MySubscriptionInfo get info => _info;

  bool get hasAccess => _info.hasAccess || reviewAccess.isEnabled;
  bool get isInTrial => _info.isInTrial;

  Future<void> refresh() async {
    isLoading = true;
    notifyListeners();

    _info = await _service.getSubscriptionStatus();

    isLoading = false;
    notifyListeners();
  }

  Future<void> restore() async {
    await _service.restore();
    await refresh();
  }
}

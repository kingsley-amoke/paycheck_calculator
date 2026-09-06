import 'package:flutter/foundation.dart';
import '../services/revenuecat_service.dart';
import '../domain/subscription_status.dart';

class SubscriptionProvider extends ChangeNotifier {
  final RevenueCatService _service;

  bool isLoading = true;

  MySubscriptionInfo _info = const MySubscriptionInfo(
    status: SubscriptionStatus.unknown,
    isActive: false,
    isInTrial: false,
  );

  MySubscriptionInfo get info => _info;

  bool get hasAccess => _info.hasAccess;
  bool get isInTrial => _info.isInTrial;

  SubscriptionProvider(this._service);

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

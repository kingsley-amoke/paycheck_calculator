import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../subscription/provider/subscription_provider.dart';

/// Counts successful calculations and pends a paywall every
/// [calcThreshold] of them for free users. The count persists across
/// sessions in the app state box, so the paywall fires on the 4th
/// distinct calculation edit burst, not on each keystroke recalcs.
///
/// Presentation listens for [shouldShowPaywall]; the display (or dismissal)
/// calls [onPaywallShown] to reset the count.
class PaywallScheduler extends ChangeNotifier {
  PaywallScheduler(this.subscription, {this.stateBox}) {
    final value = stateBox?.get(countKey);
    _count = value is int && value > 0 ? value : 0;
  }

  static const int calcThreshold = 4;
  static const String countKey = 'paywall_calc_count';

  final SubscriptionProvider subscription;

  /// Optional persistence; null keeps counting in memory (tests).
  final Box? stateBox;

  int _count = 0;

  bool get isFreeUser => !subscription.hasAccess;

  bool get shouldShowPaywall => _count >= calcThreshold && isFreeUser;

  /// Number of completed calculations since the paywall last showed.
  int get calculationsSinceLastShow => _count;

  void onCalculationCompleted() {
    _count++;
    _persist();
    notifyListeners();
  }

  void onPaywallShown() {
    _count = 0;
    _persist();
    notifyListeners();
  }

  void _persist() {
    stateBox?.put(countKey, _count);
  }
}

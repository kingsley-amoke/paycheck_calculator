import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'paywall_scheduler.dart';
import 'purchase_view.dart';

/// Shows the interval paywall above [child] when [PaywallScheduler] pends one.
///
/// Presents at most one paywall at a time. Closing it (skip or purchase)
/// resets the calculation count, so the next paywall waits for another
/// [PaywallScheduler.calcThreshold] calculations.
class PaywallHost extends StatefulWidget {
  const PaywallHost({super.key, required this.child});

  final Widget child;

  @override
  State<PaywallHost> createState() => _PaywallHostState();
}

class _PaywallHostState extends State<PaywallHost> {
  bool _showing = false;

  @override
  Widget build(BuildContext context) {
    final scheduler = context.watch<PaywallScheduler>();

    if (scheduler.shouldShowPaywall && !_showing) {
      _showing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _present(scheduler));
    }

    return widget.child;
  }

  Future<void> _present(PaywallScheduler scheduler) async {
    if (!mounted) {
      _showing = false;
      return;
    }

    final navigator = Navigator.of(context);
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (routeContext) => PurchaseView(
          onDismiss: () => navigator.pop(),
          onPurchaseSuccess: () => navigator.pop(),
        ),
      ),
    );

    scheduler.onPaywallShown();
    _showing = false;
  }
}

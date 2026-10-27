import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:paycheck_calculator/features/paywall/models/paywall_package.dart';
import 'package:paycheck_calculator/features/paywall/models/product.dart';
import 'package:paycheck_calculator/features/paywall/widgets/paywall_cta_button.dart';
import 'package:paycheck_calculator/features/paywall/widgets/paywall_footer.dart';
import 'package:paycheck_calculator/features/paywall/widgets/paywall_product_card.dart';
import 'package:paycheck_calculator/features/paywall/widgets/personalized.dart';
import 'package:paycheck_calculator/features/settings/terms_screen.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  static const Color _accent = Color(0xFF2563EB);

  List<PaywallPackage> _packages = [];
  String _selectedProductId = '';

  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      if (!mounted) return;

      if (current == null || current.availablePackages.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'No subscription plans are currently available.';
        });
        return;
      }

      final packages = current.availablePackages.map((p) {
        final product = p.storeProduct;

        return PaywallPackage(
          id: p.identifier,
          title: product.title,
          price: product.priceString,
          duration: _displayDuration(product.subscriptionPeriod ?? ''),
          hasTrial: product.introductoryPrice != null,
          package: p,
        );
      }).toList();

      setState(() {
        _packages = packages;
        _selectedProductId = packages.first.id;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      debugPrint('Failed to load subscription offerings: $e');

      setState(() {
        _isLoading = false;
        _error = 'Unable to load subscription plans. Please try again.';
      });
    }
  }

  String _displayDuration(String period) {
    if (period.contains('W')) return 'week';
    if (period.contains('M')) return 'month';
    if (period.contains('Y')) return 'year';

    return period.isEmpty ? 'subscription' : period;
  }

  double? _parsePrice(String price) {
    final cleaned = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned);
  }

  double? get _weeklyPriceDouble {
    for (final package in _packages) {
      if (package.duration == 'week') {
        final price = _parsePrice(package.price);
        if (price != null) return price;
      }
    }
    return null;
  }

  double? get _fullAnnualFromWeekly {
    final weekly = _weeklyPriceDouble;
    return weekly == null ? null : weekly * 52;
  }

  int get _percentageSaved {
    final fullAnnual = _fullAnnualFromWeekly;
    if (fullAnnual == null || fullAnnual <= 0) return 90;

    final annualPackages = _packages.where((p) => p.duration == 'year');

    if (annualPackages.isEmpty) return 90;

    final annualPrice = _parsePrice(annualPackages.first.price);
    if (annualPrice == null) return 90;

    final saved = (100 - (annualPrice / fullAnnual * 100)).round();
    return saved > 0 ? saved : 90;
  }

  String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

  PaywallPackage? get _selectedPackage {
    for (final package in _packages) {
      if (package.id == _selectedProductId) return package;
    }
    return _packages.isEmpty ? null : _packages.first;
  }

  String get _ctaLabel {
    final selected = _selectedPackage;

    if (selected == null) return 'Continue';

    return selected.hasTrial
        ? 'Start Free Trial & View Report'
        : 'Unlock My Paycheck Report';
  }

  Future<void> _purchase() async {
    final selected = _selectedPackage;
    if (selected == null || _isPurchasing) return;

    setState(() => _isPurchasing = true);

    try {
      final result = await Purchases.purchase(
        PurchaseParams.package(selected.package),
      );

      if (!mounted) return;

      final hasAccess = result.customerInfo.entitlements.active.containsKey(
        'access',
      );

      if (hasAccess) {
        Navigator.of(context).pop(true);

        // The existing app-level RevenueCat listener/provider should
        // update premium access wherever the entitlement is consumed.
      } else {
        _showMessage(
          'Purchase completed, but premium access is not yet active.',
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;

      // RevenueCat can report cancellation through a platform exception.
      // Avoid showing an error for a normal user cancellation.
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        _showMessage('Purchase could not be completed. Please try again.');
        debugPrint('Purchase error: ${e.code} ${e.message}');
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage('Something went wrong. Please try again.');
      debugPrint('Unexpected purchase error: $e');
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();

      if (!mounted) return;

      final hasAccess = customerInfo.entitlements.active.containsKey('access');

      _showMessage(
        hasAccess
            ? 'Your subscription has been restored successfully.'
            : 'No active subscription was found.',
      );

      if (hasAccess) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage('Could not restore purchases. Please try again.');
      debugPrint('Restore purchases error: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  void _openTerms() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TermsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _accent,
        elevation: 0,
        title: const Text(
          'Subscription Plans',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildError()
            : _buildPlans(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 44, color: _accent),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadOfferings();
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlans() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // HeroPlaceholder(color: _accent),
                  // const SizedBox(height: 24),
                  const Text(
                    'Choose your plan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _accent,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Unlock the full Paycheck Calculator experience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  PaywallProductCards(
                    products: _packages.map((p) {
                      return PurchaseProductDetails(
                        price: p.price,
                        productId: p.id,
                        duration: p.duration,
                        durationPlanName: p.title,
                        hasTrial: p.hasTrial,
                      );
                    }).toList(),
                    selectedProductId: _selectedProductId,
                    onSelect: (id) {
                      setState(() => _selectedProductId = id);
                    },
                    accent: _accent,
                    fullAnnualPrice: _fullAnnualFromWeekly != null
                        ? _formatCurrency(_fullAnnualFromWeekly!)
                        : null,
                    formatCurrency: _formatCurrency,
                    savingsPercent: _percentageSaved,
                  ),
                  const SizedBox(height: 24),
                  PaywallCTAButton(
                    isLoading: _isPurchasing,
                    label: _isPurchasing ? 'Processing...' : _ctaLabel,
                    accent: _accent,
                    onTap: _isPurchasing ? null : () => _purchase,
                  ),
                  const SizedBox(height: 16),
                  const TrialTrustText(),
                  const SizedBox(height: 8),
                  PaywallFooter(
                    onRestore: _restorePurchases,
                    onTerms: _openTerms,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

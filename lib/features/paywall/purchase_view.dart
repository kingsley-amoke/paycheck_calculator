import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/widgets/splash.dart';
import 'package:paycheck_calculator/features/paywall/models/paywall_package.dart';
import 'package:paycheck_calculator/features/paywall/models/product.dart';
import 'package:paycheck_calculator/features/paywall/widgets/hero_placeholder.dart';
import 'package:paycheck_calculator/features/paywall/widgets/paywall_cta_button.dart';
import 'package:paycheck_calculator/features/paywall/widgets/paywall_footer.dart';
import 'package:paycheck_calculator/features/paywall/widgets/paywall_product_card.dart';
import 'package:paycheck_calculator/features/paywall/widgets/personalized.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseView extends StatefulWidget {
  const PurchaseView({super.key});

  @override
  State<PurchaseView> createState() => _PurchaseViewState();
}

class _PurchaseViewState extends State<PurchaseView>
    with TickerProviderStateMixin {
  List<PaywallPackage> _packages = [];
  bool _isPurchasing = false;

  String _selectedProductId = '';

  static const Color _accent = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;

    if (current == null) return;

    _packages = current.availablePackages.map((p) {
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
      _selectedProductId = _packages.first.id;
    });
  }

  // ── helpers ──────────────────────────────────
  String _displayDuration(String period) {
    if (period.contains('W')) return 'week';
    if (period.contains('M')) return 'month';
    if (period.contains('Y')) return 'year';

    return period;
  }

  double? get _weeklyPriceDouble {
    final s = _packages
        .where((p) => p.duration == 'week')
        .map((p) => _parsePrice(p.price))
        .whereType<double>()
        .firstOrNull;
    return s;
  }

  double? get _fullAnnualFromWeekly {
    final w = _weeklyPriceDouble;
    return w != null ? w * 52 : null;
  }

  int get _percentageSaved {
    final full = _fullAnnualFromWeekly;
    if (full == null) return 90;
    final yearlyStr = _packages
        .where((p) => p.duration == 'year')
        .map((p) => p.price)
        .firstOrNull;
    if (yearlyStr == null) return 90;
    final yearly = _parsePrice(yearlyStr);
    if (yearly == null || full <= 0) return 90;
    final saved = (100 - (yearly / full * 100)).round();
    return saved > 0 ? saved : 90;
  }

  double? _parsePrice(String price) {
    final cleaned = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned);
  }

  String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

  String get _callToActionText {
    if (_packages.isEmpty) {
      return 'Continue';
    }

    final selected = _packages.firstWhere(
      (p) => p.id == _selectedProductId,
      orElse: () => _packages.first,
    );

    return selected.hasTrial
        ? 'Start Free Trial & View Report'
        : 'Unlock My Paycheck Report';
  }

  Future<void> _purchase() async {
    if (_selectedProductId.isEmpty) return;

    final selected = _packages.firstWhere((p) => p.id == _selectedProductId);

    final navigator = Navigator.of(context);

    try {
      setState(() => _isPurchasing = true);

      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(selected.package),
      );

      final entitlement =
          purchaseResult.customerInfo.entitlements.active['access'];

      if (entitlement != null) {
        debugPrint('purchase successfull');
        // TODO: show successfull snackbar
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainShell()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Purchase error: $e");
    } finally {
      setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      HeroPlaceholder(color: _accent),

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
                        onSelect: (id) =>
                            setState(() => _selectedProductId = id),
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
                        label: _callToActionText,
                        accent: _accent,
                        onTap: _purchase,
                      ),

                      const SizedBox(height: 16),

                      const TrialTrustText(),

                      const SizedBox(height: 8),
                      PaywallFooter(
                        onRestore: () {
                          Purchases.restorePurchases();
                        },
                        onTerms: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

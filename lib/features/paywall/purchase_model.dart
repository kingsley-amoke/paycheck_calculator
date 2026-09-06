import 'package:flutter/material.dart';
import 'models/product.dart';

class PurchaseModel extends ChangeNotifier {
  bool isFetchingProducts = true;
  bool isPurchasing = false;
  bool isSubscribed = false;

  List<PurchaseProductDetails> productDetails = [];

  PurchaseModel() {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await Future.delayed(const Duration(seconds: 1));

    productDetails = const [
      PurchaseProductDetails(
        price: '\$4.99',
        productId: 'com.app.weekly',
        duration: 'week',
        durationPlanName: 'Weekly Plan',
        hasTrial: true,
      ),
      PurchaseProductDetails(
        price: '\$39.99',
        productId: 'com.app.yearly',
        duration: 'year',
        durationPlanName: 'Yearly Plan',
        hasTrial: false,
      ),
    ];

    isFetchingProducts = false;
    notifyListeners();
  }

  Future<void> purchaseSubscription(String productId) async {
    isPurchasing = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    isSubscribed = true;
    isPurchasing = false;
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }

  String get lastProductId =>
      productDetails.isNotEmpty ? productDetails.last.productId : '';
}

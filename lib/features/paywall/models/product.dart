class PurchaseProductDetails {
  final String price;
  final String productId;
  final String duration;
  final String durationPlanName;
  final bool hasTrial;

  const PurchaseProductDetails({
    required this.price,
    required this.productId,
    required this.duration,
    required this.durationPlanName,
    required this.hasTrial,
  });
}

enum SubscriptionStatus { unknown, active, inTrial, expired }

class MySubscriptionInfo {
  final SubscriptionStatus status;
  final bool isActive;
  final bool isInTrial;
  final DateTime? expirationDate;

  const MySubscriptionInfo({
    required this.status,
    required this.isActive,
    required this.isInTrial,
    this.expirationDate,
  });

  bool get hasAccess => isActive || isInTrial;
}

import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallPackage {
  final String id;
  final String title;
  final String price;
  final String duration;
  final bool hasTrial;
  final Package package;

  PaywallPackage({
    required this.id,
    required this.title,
    required this.price,
    required this.duration,
    required this.hasTrial,
    required this.package,
  });
}

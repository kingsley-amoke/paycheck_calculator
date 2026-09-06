import 'package:flutter/material.dart';
import '../models/product.dart';

class PaywallProductCards extends StatelessWidget {
  final List<PurchaseProductDetails> products;
  final String selectedProductId;
  final Function(String) onSelect;
  final Color accent;

  final String? fullAnnualPrice;
  final String Function(double) formatCurrency;
  final int savingsPercent;

  const PaywallProductCards({
    super.key,
    required this.products,
    required this.selectedProductId,
    required this.onSelect,
    required this.accent,
    required this.formatCurrency,
    required this.savingsPercent,
    this.fullAnnualPrice,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: products.map((p) {
        final isSelected = selectedProductId == p.productId;

        final subtitle = p.hasTrial
            ? Text(
                p.price,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withOpacity(0.6),
                ),
              )
            : Row(
                children: [
                  if (fullAnnualPrice != null) ...[
                    Text(
                      fullAnnualPrice!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withOpacity(0.4),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Text(
                    p.price,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              );

        final badge = !p.hasTrial
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SAVE $savingsPercent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : null;

        return GestureDetector(
          onTap: () => onSelect(p.productId),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? accent.withOpacity(0.05) : Colors.white,
              border: Border.all(
                color: isSelected ? accent : Colors.black12,
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.durationPlanName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      subtitle,
                    ],
                  ),
                ),

                if (badge != null) ...[badge, const SizedBox(width: 10)],

                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? accent : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? accent : Colors.black26,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

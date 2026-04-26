import 'package:flutter/material.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/deduction.dart';

//TODO: add filing status to US compare screen or any other country applicable
//TODO: reconcile calculate take home and compare take home
//TODO: check settings file

class DeductionItem extends StatelessWidget {
  final Deduction deduction;
  final Country country;
  final double ratio;
  final Color color;

  const DeductionItem({
    super.key,
    required this.deduction,
    required this.ratio,
    required this.color,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deduction.name,
                softWrap: true,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                CurrencyFormatter.format(deduction.amount, country),
                softWrap: true,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

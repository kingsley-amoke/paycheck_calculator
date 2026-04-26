import 'package:flutter/material.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/paycheck_result.dart';

class NetPayHero extends StatelessWidget {
  final PaycheckResult result;
  final Country country;
  final bool isWinner;
  final String? pctBadge;

  const NetPayHero({
    super.key,
    required this.result,
    required this.country,
    required this.isWinner,
    this.pctBadge,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isWinner ? cs.secondary : cs.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                CurrencyFormatter.format(result.netIncome, country),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: color,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
            ),
            if (pctBadge != null) ...[
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isWinner ? Colors.green[600] : cs.errorContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    pctBadge!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'After all deductions',
          style: TextStyle(
            fontSize: 10,
            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

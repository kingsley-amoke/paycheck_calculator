import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/widgets/country_label.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:provider/provider.dart';

class EmptyCompareHint extends StatelessWidget {
  const EmptyCompareHint({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    int selected = 2;
    if (provider.regionA != null) {
      selected--;
    }

    if (provider.resultB != null) {
      selected--;
    }
    final cs = Theme.of(context).colorScheme;
    final remaining = 2 - selected;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: provider.taxConfig?.regions == null
                ? [
                    SizedBox(
                      width: 300,
                      child: Text(
                        'The tax bracket for ${countryLabel(provider.country)} is the same across all regions',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ]
                : [
                    Icon(
                      Icons.compare_arrows_rounded,
                      size: 48,
                      color: cs.primary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Select $remaining more region${remaining > 1 ? 's' : ''} above',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose at least 2 regions to see a comparison',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
          ),
        ),
      ],
    );
  }
}

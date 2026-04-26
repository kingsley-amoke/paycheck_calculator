import 'package:paycheck_calculator/core/widgets/filing_status_label.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import 'package:flutter/material.dart';

import '../../provider/calculator_provider.dart';

class FilingStatusSelector extends StatelessWidget {
  const FilingStatusSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();

    final availableStatuses =
        provider.taxConfig?.filingStatuses?.keys
            .map((s) => stringToFilingStatus(s))
            .whereType<FilingStatus>()
            .toList() ??
        [];

    return Container(
      padding: const EdgeInsets.only(top: 16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FILING STATUS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textGray,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: availableStatuses.map((status) {
                final selected = provider.filingStatus == status;

                return GestureDetector(
                  onTap: () => provider.setFilingStatus(status),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      filingStatusToLabel(status),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textGray,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

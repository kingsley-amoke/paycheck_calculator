import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';

class Location extends StatelessWidget {
  const Location({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final country = provider.country;
    final region = provider.selectedRegion;

    return Expanded(
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppColors.primary, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '${region?.name}, ${country.name.toUpperCase()}',
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/region_tax.dart';
import '../../provider/calculator_provider.dart';

class RegionDropdown extends StatelessWidget {
  const RegionDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final regions = provider.taxConfig?.regions?.items ?? [];

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: DropdownButton<RegionTax>(
          value: provider.selectedRegion,
          hint: Text(
            "Select Region",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: regions.isNotEmpty
                  ? AppColors.textDark
                  : AppColors.textGray,
            ),
          ),

          isExpanded: true,
          underline: const SizedBox(),
          items: regions.map((region) {
            return DropdownMenuItem(value: region, child: Text(region.name));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              provider.setRegion(value);
            }
          },
        ),
      ),
    );
  }
}

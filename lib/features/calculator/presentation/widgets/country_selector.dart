import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/flags.dart';

class CountrySelector extends StatelessWidget {
  const CountrySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'See your salary after tax instantly',
          style: TextStyle(fontSize: 14, color: AppColors.textGray),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(countries.length, (i) {
            final isSelected = countries[i].country == provider.country;
            return GestureDetector(
              onTap: () async {
                provider.setCountry(countries[i].country);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: isSelected
                      ? null
                      : Border.all(color: AppColors.divider),
                ),
                child: Text(
                  countries[i].flag,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

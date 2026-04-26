import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/widgets/pay_frequency_label.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../provider/calculator_provider.dart';

class FrequencySelector extends StatelessWidget {
  final frequencies = PayFrequency.values;

  const FrequencySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'PAY FREQUENCY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textGray,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: frequencies.reversed.map((freq) {
              final selected = provider.frequency == freq;
              return GestureDetector(
                onTap: () => provider.setFrequency(freq),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.textGray,
                    ),
                  ),
                  child: Text(
                    payFrequencyLabel(freq),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/utils/currency_formatter.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/paycheck_result.dart';

class BreakdownList extends StatelessWidget {
  final PaycheckResult result;

  const BreakdownList({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();

    return Column(
      children: [
        _item(
          provider,
          context,
          "Gross Income",
          result.grossIncome,
          Colors.green,
        ),

        ...result.deductions.map(
          (d) => _item(
            provider,
            context,
            d.name,
            -d.amount,
            taxColors[d.name] ?? Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _item(
    CalculatorProvider provider,
    BuildContext context,
    String label,
    double amount,
    Color color,
  ) {
    final isNegative = amount < 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),

          Text(
            CurrencyFormatter.format(amount, provider.country),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isNegative
                  ? Colors.red
                  : Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
        ],
      ),
    );
  }
}

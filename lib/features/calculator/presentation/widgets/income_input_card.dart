import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/calculator_provider.dart';

class IncomeInputCard extends StatelessWidget {
  const IncomeInputCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();

    final String? initialValue = provider.income > 0
        ? provider.income.toString()
        : null;

    final bool focus = provider.income > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ENTER YOUR INCOME',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 10),

          TextFormField(
            keyboardType: TextInputType.number,
            initialValue: initialValue,
            autofocus: !focus,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              prefixText: "\$ ",
              border: InputBorder.none,
            ),
            onChanged: (val) {
              final value = double.tryParse(val) ?? 0;
              provider.setIncome(value);
            },
          ),
        ],
      ),
    );
  }
}

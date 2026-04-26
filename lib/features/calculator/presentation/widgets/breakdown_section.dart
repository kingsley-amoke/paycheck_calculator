import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/calculator_provider.dart';
import 'breakdown_bar.dart';
import 'breakdown_list.dart';

class BreakdownSection extends StatelessWidget {
  const BreakdownSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, provider, _) {
        final result = provider.result;
        if (result == null) return SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Breakdown Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            AnimatedBreakdownBar(result: result),

            const SizedBox(height: 16),

            BreakdownList(result: result),
          ],
        );
      },
    );
  }
}

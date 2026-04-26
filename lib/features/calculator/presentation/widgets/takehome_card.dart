import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/calculator_provider.dart';
import 'animated_currency_text.dart';

class TakeHomeCard extends StatelessWidget {
  const TakeHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3730D8), Color(0xFF5B52F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),

        child: Consumer<CalculatorProvider>(
          builder: (context, provider, _) {
            final country = provider.country;
            final result = provider.result;

            if (result == null) return SizedBox();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR TAKE HOME PAY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: [
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4ADE80),
                        height: 1,
                      ),
                      child: AnimatedCurrencyText(
                        value: result.netIncome,
                        country: country,
                      ),
                    ),
                    SizedBox(width: 6),
                    Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: 1,
                        child: Text(
                          'annually',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(Icons.info_outline, size: 12, color: Colors.white54),
                    SizedBox(width: 4),
                    Text(
                      'After taxes and deductions',
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
                // const SizedBox(height: 20),
                // _actionButton(
                //   Icons.bookmark_border,
                //   'Save this calculation',
                //   Colors.white.withValues(alpha: 0.15),
                // ),
                // const SizedBox(height: 10),
                // _actionButton(
                //   Icons.share_outlined,
                //   'Share Statement',
                //   Colors.white.withValues(alpha: 0.15),
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _actionButton(IconData icon, String label, Color color) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 13),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';

class PaywallFooter extends StatelessWidget {
  final VoidCallback onRestore;
  final VoidCallback onTerms;

  const PaywallFooter({
    super.key,
    required this.onRestore,
    required this.onTerms,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(onTap: onRestore, child: const Text('Restore')),
        const SizedBox(width: 16),
        GestureDetector(onTap: onTerms, child: const Text('Terms & Privacy')),
      ],
    );
  }
}

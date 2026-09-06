import 'package:flutter/material.dart';

class PaywallFeatures extends StatelessWidget {
  final Color accent;

  const PaywallFeatures({super.key, required this.accent});

  @override
  Widget build(BuildContext context) {
    const features = [
      (icon: Icons.lock_open_rounded, label: 'Unlock full app functionality'),
      (icon: Icons.insights_rounded, label: 'Advanced financial tools'),
      (icon: Icons.auto_graph_rounded, label: 'Live updates & insights'),
      (icon: Icons.remove_red_eye_rounded, label: 'Ad-free experience'),
    ];

    return Column(
      children: features.map((f) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(f.icon, color: accent, size: 24),
              const SizedBox(width: 12),
              Text(f.label),
            ],
          ),
        );
      }).toList(),
    );
  }
}

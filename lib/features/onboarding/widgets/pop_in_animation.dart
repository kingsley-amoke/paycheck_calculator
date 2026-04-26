import 'package:flutter/material.dart';

class PopInAnimation extends StatelessWidget {
  final List<Animation<double>> scales;
  final List<Animation<double>> fades;
  final Widget child;
  final int index;

  const PopInAnimation({
    super.key,
    required this.scales,
    required this.fades,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fades[index],
      child: ScaleTransition(scale: scales[index], child: child),
    );
  }
}

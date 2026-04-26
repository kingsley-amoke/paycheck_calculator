import 'package:flutter/material.dart';

class FadeUpAnimation extends StatelessWidget {
  const FadeUpAnimation({
    super.key,
    required this.slides,
    required this.fades,
    required this.index,
    required this.child,
  });

  final List<Animation<Offset>> slides;
  final List<Animation<double>> fades;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fades[index],
      child: SlideTransition(position: slides[index], child: child),
    );
  }
}

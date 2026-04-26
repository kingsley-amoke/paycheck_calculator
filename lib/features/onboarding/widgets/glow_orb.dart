import 'package:flutter/material.dart';

class GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double? blur;

  const GlowOrb({
    super.key,
    required this.size,
    required this.color,
    this.blur,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: blur != null
          ? [
              BoxShadow(
                color: color,
                blurRadius: blur!,
                spreadRadius: blur! / 2,
              ),
            ]
          : null,
      color: color,
    ),
  );
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CTAButton extends StatelessWidget {
  final AnimationController pulseController;
  final void Function() onTap;
  final void Function(TapDownDetails)? onTapDown;
  final void Function(TapUpDetails)? onTapUp;
  final void Function()? onTapCancel;
  final String text;

  const CTAButton({
    super.key,
    required this.pulseController,
    required this.onTap,
    required this.text,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: pulseController,
          builder: (context, child) {
            final t = pulseController.value; // 0 → 1 → 0
            final scale = 1.0 + t * 0.02;
            final shadowBlur = 40.0 + t * 10.0;
            final shadowOpacity = 0.30 + t * 0.10;

            return Transform.scale(
              scale: scale,
              child: GestureDetector(
                onTap: onTap,
                onTapUp: onTapUp,
                onTapDown: onTapDown,
                onTapCancel: onTapCancel,
                child: Container(
                  width: double.infinity,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3525CD), Color(0xFF4F46E5)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: shadowOpacity,
                        ),
                        blurRadius: shadowBlur,
                        offset: const Offset(0, 20),
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

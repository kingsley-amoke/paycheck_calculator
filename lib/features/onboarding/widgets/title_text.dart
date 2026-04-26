import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class TitleText extends StatelessWidget {
  final String text;
  final String? styledText;

  const TitleText({super.key, required this.text, this.styledText});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 42,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
          height: 1.1,
          letterSpacing: -1.2,
        ),
        children: [
          TextSpan(text: text),
          TextSpan(
            text: styledText,
            style: TextStyle(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

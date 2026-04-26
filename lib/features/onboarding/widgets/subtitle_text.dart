import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class SubtitleText extends StatelessWidget {
  final String text;

  const SubtitleText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
        height: 1.6,
      ),
    );
  }
}

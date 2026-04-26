import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/paycheck_result.dart';

class AnimatedBreakdownBar extends StatelessWidget {
  final PaycheckResult result;

  const AnimatedBreakdownBar({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final total = result.grossIncome;

    // Build segments (gross - taxes)
    final segments = [
      _Segment(label: "Net", value: result.netIncome, color: Colors.green),
      ...result.deductions.map(
        (d) => _Segment(
          label: d.name,
          value: d.amount,
          color: taxColors[d.name] ?? Colors.grey,
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade200,
        ),
        child: Row(
          children: segments.map((s) {
            final percent = s.value / total;

            return s.value > 0
                ? Expanded(
                    flex: (percent * 1000).toInt(), // smooth ratio
                    child: _AnimatedSegment(color: s.color),
                  )
                : SizedBox();
          }).toList(),
        ),
      ),
    );
  }
}

class _Segment {
  final String label;
  final double value;
  final Color color;

  _Segment({required this.label, required this.value, required this.color});
}

class _AnimatedSegment extends StatefulWidget {
  final Color color;

  const _AnimatedSegment({required this.color});

  @override
  State<_AnimatedSegment> createState() => _AnimatedSegmentState();
}

class _AnimatedSegmentState extends State<_AnimatedSegment>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) {
        return FractionallySizedBox(
          widthFactor: animation.value,
          child: Container(color: widget.color),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

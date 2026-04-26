import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/constants/enums.dart';
import 'package:paycheck_calculator/core/utils/currency_formatter.dart';

class AnimatedCurrencyText extends StatefulWidget {
  final double value;
  final Country country;
  final Duration duration;

  const AnimatedCurrencyText({
    super.key,
    required this.value,
    this.country = Country.us,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedCurrencyText> createState() => _AnimatedCurrencyTextState();
}

class _AnimatedCurrencyTextState extends State<AnimatedCurrencyText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  double oldValue = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCurrencyText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      oldValue = oldWidget.value;

      _animation = Tween<double>(begin: oldValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );

      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, _) {
        final val = _animation.value;

        return Text(
          CurrencyFormatter.format(val, widget.country),
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

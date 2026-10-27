import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/usecases/annual_projection.dart';

enum ProjectionSeries { net, gross }

const _monthLetters = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

/// Twelve month bars, value-scaled, single selectable series (Net or Gross).
/// Bars recompute on layout width via [LayoutBuilder].
class MonthlyBarsChart extends StatefulWidget {
  const MonthlyBarsChart({super.key, required this.points});

  final List<MonthlyProjectionPoint> points;

  @override
  State<MonthlyBarsChart> createState() => _MonthlyBarsChartState();
}

class _MonthlyBarsChartState extends State<MonthlyBarsChart> {
  ProjectionSeries _series = ProjectionSeries.net;
  double? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onHorizontalDragDown: (details) => setState(() {
                final bar = (details.localPosition.dx /
                        constraints.maxWidth.floorToDouble())
                    .clamp(0, 12)
                    .toInt();
                _selectedMonth = bar.toDouble() + 1;
              }),
              onTapUp: (details) {
                final bar = (details.localPosition.dx /
                        (constraints.maxWidth / 12))
                    .floor()
                    .clamp(0, 11);
                setState(() => _selectedMonth = bar.toDouble() + 1);
              },
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CustomPaint(
                  painter: MonthlyBarsChartPainter(
                    points: widget.points,
                    series: _series,
                    selectedMonth: _selectedMonth,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final s in ProjectionSeries.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        s == ProjectionSeries.net ? 'Net' : 'Gross',
                      ),
                      selected: _series == s,
                      onSelected: (_) => setState(() {
                        _series = s;
                        _selectedMonth = null;
                      }),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Draws 12 value-scaled month bars with single-letter month labels.
class MonthlyBarsChartPainter extends CustomPainter {
  const MonthlyBarsChartPainter({
    required this.points,
    required this.series,
    this.selectedMonth,
  });

  final List<MonthlyProjectionPoint> points;
  final ProjectionSeries series;
  final double? selectedMonth;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length != 12) return;

    const chartBottomPad = 16.0;
    final chartHeight = size.height - chartBottomPad;
    final slot = size.width / 12;
    final barWidth = slot * 0.62;

    final max = points.fold<double>(
      0,
      (m, p) => (series == ProjectionSeries.net ? p.net : p.gross) > m
          ? (series == ProjectionSeries.net ? p.net : p.gross)
          : m,
    );

    for (var i = 0; i < 12; i++) {
      final value = series == ProjectionSeries.net
          ? points[i].net
          : points[i].gross;
      final h = max > 0 ? chartHeight * (value / max) : 0.0;
      final isSel = selectedMonth == (i + 1);

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          i * slot + (slot - barWidth) / 2,
          chartHeight - h,
          barWidth,
          h,
        ),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = isSel ? AppColors.primary : AppColors.textLight,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: _monthLetters[i],
          style: const TextStyle(fontSize: 10, color: AppColors.textGray),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(i * slot + (slot - tp.width) / 2, chartHeight + 2));
    }

    // baseline
    canvas.drawLine(
      Offset(0, chartHeight),
      Offset(size.width, chartHeight),
      Paint()
        ..color = AppColors.divider
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant MonthlyBarsChartPainter old) =>
      old.series != series ||
      old.selectedMonth != selectedMonth ||
      old.points != points;
}

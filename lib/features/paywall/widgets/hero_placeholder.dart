import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/constants/app_colors.dart';
import 'package:paycheck_calculator/core/widgets/filing_status_label.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:provider/provider.dart';

class HeroPlaceholder extends StatelessWidget {
  final Color color;

  const HeroPlaceholder({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CalculatorProvider>();

    final monthlyNet = provider.result!.netIncome / 12;

    final double federalTax = provider.result!.deductions
        .firstWhere((d) => d.name == 'Income Tax')
        .amount;

    final stateTax = provider.result!.deductions
        .firstWhere((d) => d.name == '${provider.selectedRegion?.name} Tax')
        .amount;

    double fraction(double amount) {
      return amount / provider.income;
    }

    String percentage(double amount) {
      return '${((amount / provider.income) * 100).toStringAsFixed(0)}%';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.primary.withValues(alpha: 0.03)],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            spreadRadius: -6,
            offset: const Offset(0, 10),
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── SOFT GLOW ───────────────────────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ROW ────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'REPORT READY',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.04),
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_graph_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── TITLE ─────────────────────────────────────────────
              Text(
                'Estimated Take-Home Pay',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withValues(alpha: 0.55),
                ),
              ),

              const SizedBox(height: 8),

              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [AppColors.onSurface, AppColors.primary],
                  ).createShader(bounds);
                },
                child: Text(
                  '\$${monthlyNet.toStringAsFixed(0)}/mo',
                  style: const TextStyle(
                    fontSize: 44,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1.5,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: Colors.black.withValues(alpha: 0.45),
                  ),

                  const SizedBox(width: 2),

                  Text(
                    provider.selectedRegion?.name ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withValues(alpha: 0.55),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.25),
                      ),
                    ),
                  ),

                  Text(
                    filingStatusToLabel(provider.filingStatus),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── TAX BREAKDOWN CARD ───────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.04),
                  ),
                ),
                child: Column(
                  children: [
                    _TaxRow(
                      label: 'Federal Tax',
                      value: percentage(federalTax),
                      progress: fraction(federalTax),
                    ),

                    const SizedBox(height: 16),

                    _TaxRow(
                      label: 'State Tax',
                      value: percentage(stateTax),
                      progress: fraction(stateTax),
                    ),

                    const SizedBox(height: 16),

                    _TaxRow(
                      label: 'Net Income',
                      value: percentage(provider.result!.netIncome),
                      progress: fraction(provider.result!.netIncome),
                      highlighted: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'PREMIUM INSIGHTS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Opacity(
                opacity: 0.45,
                child: Column(
                  children: const [
                    _PremiumInsightRow(
                      icon: Icons.pie_chart_rounded,
                      title: 'Effective Tax Rate',
                    ),
                    SizedBox(height: 8),
                    _PremiumInsightRow(
                      icon: Icons.stacked_bar_chart_rounded,
                      title: 'Deduction Analysis',
                    ),
                    SizedBox(height: 8),
                    _PremiumInsightRow(
                      icon: Icons.compare_arrows_rounded,
                      title: 'State Comparison Report',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaxRow extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final bool highlighted;

  const _TaxRow({
    required this.label,
    required this.value,
    required this.progress,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: highlighted ? FontWeight.w700 : FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),

            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: highlighted
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(
              highlighted
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
        ),
      ],
    );
  }
}

class _PremiumInsightRow extends StatelessWidget {
  final IconData icon;
  final String title;

  const _PremiumInsightRow({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),

        const SizedBox(width: 4),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),

        const Icon(Icons.lock_rounded, size: 18, color: AppColors.primary),
      ],
    );
  }
}

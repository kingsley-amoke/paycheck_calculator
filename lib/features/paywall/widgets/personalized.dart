// ─────────────────────────────────────────────────────────────────────────────
// PERSONALIZED PAYWALL COMPONENTS
// Designed specifically for your paycheck/tax analysis app
// Matches your existing premium aesthetic and animation style
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. PERSONALIZED REPORT PREVIEW
// ─────────────────────────────────────────────────────────────────────────────

class PersonalizedReportPreview extends StatelessWidget {
  final double salary;
  final String state;
  final String filingStatus;

  const PersonalizedReportPreview({
    super.key,
    required this.salary,
    required this.state,
    required this.filingStatus,
  });

  @override
  Widget build(BuildContext context) {
    final monthlyNet = ((salary * 0.73) / 12);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.02),
          ],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Badge ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              'Your Paycheck Report Is Ready',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Salary ─────────────────────────────────────────────────
          const Text(
            'Estimated Take-Home Pay',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            '\$${monthlyNet.toStringAsFixed(0)}/mo',
            style: const TextStyle(
              fontSize: 42,
              height: 1,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '$state • $filingStatus',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 28),

          // ── Breakdown ──────────────────────────────────────────────
          _TaxRow(label: 'Federal Tax', value: '18%', progress: 0.18),

          const SizedBox(height: 16),

          _TaxRow(label: 'State Tax', value: '7%', progress: 0.07),

          const SizedBox(height: 16),

          _TaxRow(
            label: 'Net Income',
            value: '75%',
            progress: 0.75,
            highlighted: true,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. GENERATED ANALYSIS SECTION
// ─────────────────────────────────────────────────────────────────────────────

class GeneratedInsightsCard extends StatelessWidget {
  const GeneratedInsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      'Take-home pay calculated',
      'Federal tax analyzed',
      'State deductions estimated',
      'Effective tax rate generated',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Report Includes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 20),

          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. LOCKED ANALYTICS PREVIEW
// ─────────────────────────────────────────────────────────────────────────────

class LockedAnalyticsPreview extends StatelessWidget {
  const LockedAnalyticsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Premium Tax Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 24),

                _LockedRow(title: 'Effective Tax Rate'),
                const SizedBox(height: 20),

                _LockedRow(title: 'Annual Tax Breakdown'),
                const SizedBox(height: 20),

                _LockedRow(title: 'Net Salary Projection'),
                const SizedBox(height: 20),

                _LockedRow(title: 'Tax Optimization Insights'),
              ],
            ),
          ),

          // ── Blur Overlay ────────────────────────────────────────────
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.white.withValues(alpha: 0.15)),
            ),
          ),

          // ── Center Lock ─────────────────────────────────────────────
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 30,
                      spreadRadius: 4,
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 38,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. PREMIUM TRUST TEXT
// ─────────────────────────────────────────────────────────────────────────────

class TrialTrustText extends StatelessWidget {
  const TrialTrustText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Cancel anytime during your free trial.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withValues(alpha: 0.55),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'No commitment. Full access instantly.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black.withValues(alpha: 0.40),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

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
                  fontSize: 15,
                  fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),

            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                color: highlighted
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
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

class _LockedRow extends StatelessWidget {
  final String title;

  const _LockedRow({required this.title});

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
          child: const Icon(Icons.analytics_rounded, color: AppColors.primary),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Container(
            height: 14,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ],
    );
  }
}

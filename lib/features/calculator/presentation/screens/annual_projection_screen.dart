import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/calculator/provider/comparison_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/calculation_profile.dart';
import '../../../../core/widgets/pay_frequency_label.dart';
import '../../../../domain/entities/paycheck_result.dart';
import '../../../../domain/usecases/annual_projection.dart';
import '../../provider/profile_provider.dart';
import '../widgets/monthly_bars_chart.dart';

class AnnualProjectionScreen extends StatelessWidget {
  const AnnualProjectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ProfileProvider>();
    final profile = profiles.activeProfile;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'Annual projection',
      //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      //   ),
      // ),
      body: SafeArea(
        child: profile == null
            ? const _NoProfileNote()
            : _Projection(profile: profile),
      ),
    );
  }
}

class _NoProfileNote extends StatelessWidget {
  const _NoProfileNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                size: 38,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your year at a glance',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Save a calculation and make it your active profile to '
              'see your projected monthly and annual income.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Projection extends StatelessWidget {
  const _Projection({required this.profile});

  final CalculationProfile profile;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PaycheckResult>(
      future: calculateProfileResult(profile),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ProjectionError(message: 'Projection unavailable.');
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final result = snapshot.data;
        if (result == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final points = projectYear(profile, result);
        final country = profile.country;
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _ProjectionHeader(profile: profile),
            const SizedBox(height: 20),

            // Primary metric: annual take-home pay.
            _AnnualNetCard(value: result.netIncome, country: country),
            const SizedBox(height: 12),

            // Secondary annual total.
            Row(
              children: [
                Expanded(
                  child: _TotalTile(
                    label: 'Annual gross',
                    value: result.grossIncome,
                    country: country,
                    icon: Icons.payments_outlined,
                    accent: colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TotalTile(
                    label: 'Estimated deductions',
                    value: result.grossIncome - result.netIncome,
                    country: country,
                    icon: Icons.account_balance_outlined,
                    accent: colors.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            _SectionHeading(
              title: 'Monthly breakdown',
              subtitle:
                  'Explore how your projected pay is distributed '
                  'across the year.',
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: MonthlyBarsChart(points: points),
            ),
            const SizedBox(height: 20),

            _ProjectionNote(
              text:
                  'This projection distributes '
                  '${payFrequencyLabel(profile.payFrequency).toLowerCase()} '
                  'paydays by calendar pay dates. Withholding uses the '
                  'engine’s annualized estimate. Actual annual taxes and '
                  'credits may differ.',
            ),
          ],
        );
      },
    );
  }
}

class _ProjectionHeader extends StatelessWidget {
  const _ProjectionHeader({required this.profile});

  final CalculationProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.calendar_view_month_rounded,
            color: colors.onPrimaryContainer,
            size: 25,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your annual outlook',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '12 months',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnnualNetCard extends StatelessWidget {
  const _AnnualNetCard({required this.value, required this.country});

  final double value;
  final Country country;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.primary.withValues(alpha: 0.82)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 20,
                color: colors.onPrimary.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 8),
              Text(
                'PROJECTED ANNUAL TAKE-HOME',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onPrimary.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(value, country),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.7,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estimated net income for the year',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalTile extends StatelessWidget {
  const _TotalTile({
    required this.label,
    required this.value,
    required this.country,
    required this.icon,
    required this.accent,
  });

  final String label;
  final double value;
  final Country country;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(height: 13),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                CurrencyFormatter.format(value, country),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ProjectionNote extends StatelessWidget {
  const _ProjectionNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 19,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectionError extends StatelessWidget {
  const _ProjectionError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 42, color: colors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check the saved calculation and try again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

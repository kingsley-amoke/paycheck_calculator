import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/calculation_profile.dart';
import '../../../../core/widgets/pay_frequency_label.dart';
import '../../../../domain/entities/paycheck_result.dart';
import '../../../../domain/usecases/annual_projection.dart';
import '../../provider/comparison_provider.dart';
import '../../provider/profile_provider.dart';
import '../widgets/monthly_bars_chart.dart';

/// Annual projection of the ACTIVE profile: 12 calendar month bars from
/// the engine's annualized result. No second tax engine — projectYear
/// only distributes the engine's totals by calendar paydays.
class AnnualProjectionScreen extends StatelessWidget {
  const AnnualProjectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ProfileProvider>();
    final profile = profiles.activeProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Annual Projection',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Save a calculation to see its annual projection by month.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textGray),
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
          return Center(
            child: Text(
              'Projection unavailable: ${snapshot.error}',
              style: const TextStyle(fontSize: 13, color: AppColors.red),
            ),
          );
        }
        final result = snapshot.data;
        if (result == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final points = projectYear(profile, result);
        final country = profile.country;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  MonthlyBarsChart(points: points),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _TotalTile(
                          label: 'Annual gross',
                          value: result.grossIncome,
                          country: country,
                        ),
                      ),
                      Expanded(
                        child: _TotalTile(
                          label: 'Annual net',
                          value: result.netIncome,
                          country: country,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Projection distributes '
              '${payFrequencyLabel(profile.payFrequency).toLowerCase()} '
              'paydays by calendar pay dates; withholding is the engine\'s '
              'annualized estimate; taxes/credits not modeled.',
              style: const TextStyle(fontSize: 11, color: AppColors.textLight),
            ),
          ],
        );
      },
    );
  }
}

class _TotalTile extends StatelessWidget {
  const _TotalTile({
    required this.label,
    required this.value,
    required this.country,
  });

  final String label;
  final double value;
  final Country country;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textGray),
        ),
        Text(
          CurrencyFormatter.format(value, country),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

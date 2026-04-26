import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/breakdown_section.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/country_selector.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/income_input_card.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/location.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/pay_frequency_selector.dart';
import 'package:paycheck_calculator/features/paywall/paywall_screen_2.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../paywall/paywall_screen.dart';
import '../../provider/calculator_provider.dart';
import '../widgets/filing_status_selector.dart';
import '../widgets/region_dropdown.dart';
import '../widgets/takehome_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final config = provider.taxConfig;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 20, 0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: CountrySelector()),
              if (config?.regions != null)
                SliverToBoxAdapter(child: _buildLocationRow()),
              SliverToBoxAdapter(child: IncomeInputCard()),
              SliverToBoxAdapter(child: FrequencySelector()),
              if (config?.filingStatuses != null)
                SliverToBoxAdapter(child: FilingStatusSelector()),
              SliverToBoxAdapter(child: TakeHomeCard()),
              SliverToBoxAdapter(child: BreakdownSection()),
              // SliverToBoxAdapter(child: _buildRecentScenarios()),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Paycheck',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _showPaywall(context),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.yellow.withValues(alpha: 0.8),
            child: ClipOval(
              child: Container(
                width: 36,
                height: 36,
                color: Colors.amberAccent[700],
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow() {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'TAX STATE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textGray,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [Location(), RegionDropdown()]),
        ],
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PurchaseView(
          onDismiss: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/breakdown_section.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/country_selector.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/home_header.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/income_input_card.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/location.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/pay_frequency_selector.dart';

import '../widgets/filing_status_selector.dart';
import '../widgets/region_dropdown.dart';
import '../widgets/save_profile_sheet.dart';
import '../widgets/overtime_section.dart';
import '../widgets/extra_income_section.dart';
import '../widgets/user_deductions_section.dart';
import '../widgets/takehome_card.dart';
import 'saved_calculations_screen.dart';

import '../../../../core/constants/app_colors.dart';
import '../../provider/calculator_provider.dart';
import 'package:provider/provider.dart';

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
              SliverToBoxAdapter(
                child: HomeHeader(
                  onSave: () => showSaveProfileSheet(context),
                  onSavedCalculations: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SavedCalculationsScreen(),
                    ),
                  ),
                  onCompare: () {},
                  onAnnualProjection: () {},
                  hasUnsavedChanges: false,
                ),
              ),
              SliverToBoxAdapter(child: CountrySelector()),
              if (config?.regions != null)
                SliverToBoxAdapter(child: _buildLocationRow()),
              SliverToBoxAdapter(child: IncomeInputCard()),
              SliverToBoxAdapter(child: FrequencySelector()),
              if (config?.filingStatuses != null)
                SliverToBoxAdapter(child: FilingStatusSelector()),
              SliverToBoxAdapter(child: TakeHomeCard()),
              SliverToBoxAdapter(child: BreakdownSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(child: OvertimeSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(child: ExtraIncomeSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(child: UserDeductionsSection()),

              // SliverToBoxAdapter(child: _buildRecentScenarios()),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
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
}

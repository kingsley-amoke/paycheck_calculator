import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/breakdown_section.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/country_selector.dart';
import 'package:paycheck_calculator/features/paywall/subscription_plans_screen.dart';
import 'package:paycheck_calculator/features/subscription/domain/feature_access.dart';
import 'package:paycheck_calculator/features/subscription/provider/subscription_provider.dart';
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
import 'compare_calculations_screen.dart';
import 'annual_projection_screen.dart';

import '../../../../core/constants/app_colors.dart';
import '../../provider/calculator_provider.dart';
import '../../provider/profile_provider.dart';
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
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: CountrySelector()),
              if (config?.regions != null)
                SliverToBoxAdapter(child: _buildLocationRow()),
              SliverToBoxAdapter(child: IncomeInputCard()),
              SliverToBoxAdapter(child: FrequencySelector()),
              if (config?.filingStatuses != null)
                SliverToBoxAdapter(child: FilingStatusSelector()),
              SliverToBoxAdapter(child: OvertimeSection()),
              SliverToBoxAdapter(child: ExtraIncomeSection()),
              SliverToBoxAdapter(child: UserDeductionsSection()),
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
    final profiles = context.watch<ProfileProvider>();
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Paycheck Calculator',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_add_outlined),
          tooltip: 'Save as profile',
          color: profiles.hasUnsavedChanges ? Colors.amber : null,
          onPressed: () => showSaveProfileSheet(context),
        ),
        IconButton(
          icon: const Icon(Icons.list_alt),
          tooltip: 'Saved calculations',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SavedCalculationsScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.compare_arrows),
          tooltip: 'Compare calculations',
          onPressed: () async {
            final canCompare = _canCompare();
            if (canCompare) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CompareCalculationsScreen(),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SubscriptionPlansScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.insert_chart_outlined),
          tooltip: 'Annual projection',
          onPressed: () async {
            final canProject = _canProject();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => canProject
                    ? const AnnualProjectionScreen()
                    : const SubscriptionPlansScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Free users can still browse; projection itself is premium.
  bool _canProject() {
    try {
      return FeatureAccess.canProject(
        context.read<SubscriptionProvider>().hasAccess,
      );
    } on ProviderNotFoundException {
      // test/dev wiring without subscription provider — treated as free.
      return false;
    }
  }

  /// Free users can still browse; comparison itself is premium.
  bool _canCompare() {
    try {
      return FeatureAccess.canCompare(
        context.read<SubscriptionProvider>().hasAccess,
      );
    } on ProviderNotFoundException {
      // test/dev wiring without subscription provider — treated as free.
      return false;
    }
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

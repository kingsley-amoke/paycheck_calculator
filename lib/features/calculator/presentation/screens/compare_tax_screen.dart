// import 'package:flutter/material.dart';
// import 'package:paycheck_calculator/features/calculator/presentation/widgets/comparison_section.dart';
// import 'package:paycheck_calculator/features/calculator/presentation/widgets/scenario_selector_section.dart';
// import 'package:provider/provider.dart';
// import '../../provider/calculator_provider.dart';
// import '../widgets/empty_compare_hint.dart';

// class CompareTaxScreen extends StatefulWidget {
//   const CompareTaxScreen({super.key});

//   @override
//   State<CompareTaxScreen> createState() => _CompareTaxScreenState();
// }

// class _CompareTaxScreenState extends State<CompareTaxScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     )..forward();
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeOut,
//     );
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<CalculatorProvider>();
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: CustomScrollView(
//           slivers: [
//             // _buildAppBar(context),
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 46, 16, 100),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ScenarioSelectorSection(),
//                     const SizedBox(height: 24),
//                     if (provider.regionA != null || provider.regionB != null)
//                       ComparisonSection()
//                     else
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [EmptyCompareHint()],
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/comparison_section.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/scenario_selector_section.dart';
import 'package:provider/provider.dart';

import '../../provider/calculator_provider.dart';
import '../widgets/empty_compare_hint.dart';

class CompareTaxScreen extends StatefulWidget {
  const CompareTaxScreen({super.key});

  @override
  State<CompareTaxScreen> createState() => _CompareTaxScreenState();
}

class _CompareTaxScreenState extends State<CompareTaxScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasRegions = provider.regionA != null || provider.regionB != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(context),
                    const SizedBox(height: 12),
                    Text(
                      'See how location affects your paycheck.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Existing region/scenario selector.
                    const ScenarioSelectorSection(),

                    const SizedBox(height: 20),

                    if (hasRegions)
                      const ComparisonSection()
                    else
                      const EmptyCompareHint(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Material(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(14),
            child: const SizedBox(
              height: 44,
              width: 44,
              child: Icon(Icons.arrow_back_rounded),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Region comparison',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.public_rounded, color: colors.primary),
        ),
      ],
    );
  }
}

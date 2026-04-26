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
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 46, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScenarioSelectorSection(),
                    const SizedBox(height: 24),
                    if (provider.regionA != null || provider.regionB != null)
                      ComparisonSection()
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [EmptyCompareHint()],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/calculator/presentation/screens/compare_calculations_screen.dart';
import 'package:paycheck_calculator/features/calculator/presentation/screens/compare_tax_screen.dart';
import 'package:paycheck_calculator/features/paywall/subscription_plans_screen.dart';
import 'package:paycheck_calculator/features/subscription/provider/subscription_provider.dart';
import 'package:provider/provider.dart';

class CompareHubScreen extends StatelessWidget {
  const CompareHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // _buildHeader(context),
                  // const SizedBox(height: 24),
                  _buildIntro(context),
                  const SizedBox(height: 28),

                  _CompareFeatureCard(
                    icon: Icons.public_rounded,
                    title: 'Compare regions',
                    subtitle: 'Find out where your paycheck goes further.',
                    description:
                        'Compare taxes and estimated take-home pay across '
                        'supported regions using the same income.',
                    badge: 'FREE',
                    iconColor: const Color(0xFF3730D8),
                    iconBackground: const Color(0xFFE9E8FF),
                    bullets: const [
                      'Compare tax differences',
                      'Explore regional take-home pay',
                    ],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CompareTaxScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  _CompareFeatureCard(
                    icon: Icons.compare_arrows_rounded,
                    title: 'Compare profiles',
                    subtitle: 'Compare your saved salary scenarios.',
                    description:
                        'See how different incomes, pay arrangements, and '
                        'saved calculations compare side by side.',
                    badge: 'PREMIUM',
                    iconColor: const Color(0xFF087F8C),
                    iconBackground: const Color(0xFFDDF7F6),
                    bullets: const [
                      'Compare saved calculations',
                      'Evaluate different salary scenarios',
                    ],
                    onTap: () => _openProfileComparison(context),
                  ),

                  const SizedBox(height: 24),
                  _buildTip(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.compare_arrows_rounded,
            color: colors.primary,
            size: 27,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'Compare',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntro(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Make smarter pay decisions.',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Explore how your take-home pay changes by location or '
          'compare different salary scenarios.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  Widget _buildTip(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: colors.primary,
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Which comparison should I use?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Use Regions to explore location-based tax differences. '
                  'Use Profiles to compare saved personal scenarios.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openProfileComparison(BuildContext context) {
    final subscription = context.read<SubscriptionProvider>();

    if (subscription.hasAccess) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const CompareCalculationsScreen(),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const SubscriptionPlansScreen(),
        ),
      );
    }
  }
}

class _CompareFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final String badge;
  final Color iconColor;
  final Color iconBackground;
  final List<String> bullets;
  final VoidCallback onTap;

  const _CompareFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.badge,
    required this.iconColor,
    required this.iconBackground,
    required this.bullets,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isPremium = badge == 'PREMIUM';

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: iconColor, size: 27),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? colors.tertiary.withValues(alpha: 0.12)
                          : colors.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      badge,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isPremium ? colors.tertiary : colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ...bullets.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 17,
                        color: iconColor,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          item,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: isPremium
                        ? colors.primary
                        : colors.primary,
                    foregroundColor: colors.onPrimary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(isPremium ? 'Explore premium' : 'Compare regions'),
                      const SizedBox(width: 8),
                      Icon(
                        isPremium
                            ? Icons.lock_open_rounded
                            : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

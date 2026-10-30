import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/comparison_provider.dart';
import '../../provider/profile_provider.dart';
import '../widgets/comparison_table.dart';

/// Compare 2–4 saved calculations side by side via the existing engine.
/// Read-only: never mutates profiles or the working calculator.
class CompareCalculationsScreen extends StatefulWidget {
  const CompareCalculationsScreen({super.key});

  @override
  State<CompareCalculationsScreen> createState() =>
      _CompareCalculationsScreenState();
}

class _CompareCalculationsScreenState extends State<CompareCalculationsScreen> {
  List<String>? _computedFor;
  Future<List<ComparisonRow>>? _rowsFuture;

  Future<List<ComparisonRow>> _rows(
    ComparisonProvider comparison,
    ProfileProvider profiles,
  ) {
    // Keep the existing memoization behavior.
    _rowsFuture ??= comparison.computeRows(profiles.profiles);
    return _rowsFuture!;
  }

  @override
  Widget build(BuildContext context) {
    final comparison = context.watch<ComparisonProvider>();
    final profiles = context.watch<ProfileProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_computedFor?.join(',') != comparison.selectedIds.join(',')) {
      _computedFor = List.of(comparison.selectedIds);
      _rowsFuture = null;
    }

    final selected = comparison.selectedIds
        .where((id) => profiles.profiles.any((p) => p.id == id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compare calculations',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _buildIntro(theme, colors),
            const SizedBox(height: 24),

            _buildSectionHeading(
              context,
              number: '01',
              title: 'Choose calculations',
              subtitle: 'Select the saved profiles you want to compare.',
            ),
            const SizedBox(height: 14),

            if (profiles.profiles.isEmpty)
              _buildEmptyProfiles(context)
            else ...[
              _buildSelectionCard(
                context,
                comparison: comparison,
                profiles: profiles,
                selectedCount: selected.length,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    selected.length >= 2
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    size: 16,
                    color: selected.length >= 2
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selected.length < 2
                          ? 'Select at least 2 calculations to compare.'
                          : '${selected.length} calculations selected',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (selected.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        for (final id in List<String>.of(
                          comparison.selectedIds,
                        )) {
                          comparison.toggle(id);
                        }
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ],

            const SizedBox(height: 28),

            if (selected.length >= 2) ...[
              _buildSectionHeading(
                context,
                number: '02',
                title: 'Results',
                subtitle: 'Review the estimated take-home pay side by side.',
              ),
              const SizedBox(height: 14),
              FutureBuilder<List<ComparisonRow>>(
                future: _rows(comparison, profiles),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return _buildLoadingState(context);
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState(context);
                  }

                  final rows = snapshot.data;

                  if (rows == null || rows.length < 2) {
                    return _buildLoadingState(context);
                  }

                  ComparisonRow winner = rows.first;
                  for (final row in rows.skip(1)) {
                    if (row.result.netIncome > winner.result.netIncome) {
                      winner = row;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ComparisonTable(rows: rows),
                      const SizedBox(height: 16),
                      _winnerBanner(context, winner.profile.name),
                      const SizedBox(height: 12),
                      _buildDisclaimer(context),
                    ],
                  );
                },
              ),
            ] else ...[
              _buildComparePlaceholder(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIntro(ThemeData theme, ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.85),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make a smarter choice',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Compare saved paycheck estimates to see how '
                  'different scenarios affect your take-home pay.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(
    BuildContext context, {
    required String number,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            number,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionCard(
    BuildContext context, {
    required ComparisonProvider comparison,
    required ProfileProvider profiles,
    required int selectedCount,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.library_books_outlined,
                color: colors.primary,
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Saved profiles',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$selectedCount selected',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          for (int i = 0; i < profiles.profiles.length; i++) ...[
            Builder(
              builder: (context) {
                final profile = profiles.profiles[i];
                final isSelected = comparison.isSelected(profile.id);

                return Material(
                  color: isSelected
                      ? colors.primaryContainer.withValues(alpha: 0.38)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(13),
                    onTap: () => comparison.toggle(profile.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primary.withValues(alpha: 0.12)
                                  : colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              color: isSelected
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              profile.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: isSelected
                                    ? colors.primary
                                    : colors.outline,
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 17,
                                    color: colors.onPrimary,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (i != profiles.profiles.length - 1) const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyProfiles(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 38,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No saved calculations yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Save a calculation first. Your saved profiles will appear here '
            'so you can compare them.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparePlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.compare_arrows_rounded,
            size: 32,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            'Your comparison will appear here',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            'Choose at least two saved calculations above to see the results.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Could not load the comparison. Please try changing your '
              'selected calculations.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _winnerBanner(BuildContext context, String name) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.secondary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.75),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_up_rounded,
              color: colors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Higher net pay',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.verified_rounded, color: colors.secondary),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Withholding estimates only. Actual annual tax liability may '
              'differ based on total income, credits, and other factors.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

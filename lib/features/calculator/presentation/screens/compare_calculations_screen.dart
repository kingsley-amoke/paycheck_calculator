import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
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
    // Memoized per selection; deleted-profile ids are filtered inside the
    // provider so a mid-session delete cannot crash the table.
    _rowsFuture ??= comparison.computeRows(profiles.profiles);
    return _rowsFuture!;
  }

  @override
  Widget build(BuildContext context) {
    final comparison = context.watch<ComparisonProvider>();
    final profiles = context.watch<ProfileProvider>();

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
          'Compare Calculations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final p in profiles.profiles)
                  FilterChip(
                    label: Text(p.name),
                    selected: comparison.isSelected(p.id),
                    onSelected: (_) => comparison.toggle(p.id),
                    // ✕ removes a selected profile from the comparison.
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: comparison.isSelected(p.id)
                        ? () => comparison.toggle(p.id)
                        : null,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (selected.length < 2) ...[
              Text(
                'Select at least two calculations',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textGray,
                ),
              ),
            ] else ...[
              FutureBuilder<List<ComparisonRow>>(
                future: _rows(comparison, profiles),
                builder: (context, snapshot) {
                  final rows = snapshot.data;
                  if (rows == null || rows.length < 2) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  ComparisonRow winner = rows.first;
                  for (final r in rows.skip(1)) {
                    if (r.result.netIncome > winner.result.netIncome) {
                      winner = r;
                    }
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ComparisonTable(rows: rows),
                      const SizedBox(height: 16),
                      _winnerBanner(winner.profile.name),
                      const SizedBox(height: 8),
                      const Text(
                        'Withholding estimates only — annual liability '
                        'depends on totals and credits.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _winnerBanner(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Higher net pay: $name',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}

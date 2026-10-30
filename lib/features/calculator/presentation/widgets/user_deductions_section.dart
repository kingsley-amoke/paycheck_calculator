// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../../../data/models/calculation_profile.dart';
// import '../../provider/calculator_provider.dart';
// import 'section_scaffold.dart';

// class UserDeductionsSection extends StatelessWidget {
//   const UserDeductionsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final calc = context.watch<CalculatorProvider>();
//     final preTax = calc.userDeductions.where((d) => d.preTax).toList();
//     final postTax = calc.userDeductions.where((d) => !d.preTax).toList();

//     return SectionCard(
//       label: 'DEDUCTIONS',
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (calc.userDeductions.isEmpty)
//             const Text(
//               '401(k), HSA, insurance premiums, other deductions.',
//               style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
//             ),
//           if (preTax.isNotEmpty) ...[
//             const SizedBox(height: 4),
//             const Text(
//               'PRE-TAX',
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 1,
//                 color: Color(0xFF16A34A),
//               ),
//             ),
//             for (final d in preTax) _deductionRow(calc, d),
//           ],
//           if (postTax.isNotEmpty) ...[
//             const SizedBox(height: 4),
//             const Text(
//               'POST-TAX',
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 1,
//                 color: Color(0xFF6B7280),
//               ),
//             ),
//             for (final d in postTax) _deductionRow(calc, d),
//           ],
//           addRowButton(() => showDeductionSheet(context, calc, null)),
//         ],
//       ),
//     );
//   }

//   Widget _deductionRow(CalculatorProvider calc, UserDeduction d) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 6),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               d.name,
//               style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//             ),
//           ),
//           Text(
//             d.isPercentage ? '${fmtPct(d.value)}% of gross' : fmtPct(d.value),
//             style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete_outline, size: 20),
//             onPressed: () => calc.removeDeduction(d.id),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/calculation_profile.dart';
import '../../provider/calculator_provider.dart';
import 'section_scaffold.dart';

class UserDeductionsSection extends StatelessWidget {
  const UserDeductionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final preTax = calc.userDeductions.where((d) => d.preTax).toList();
    final postTax = calc.userDeductions.where((d) => !d.preTax).toList();
    final hasDeductions = calc.userDeductions.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasDeductions
              ? colors.primary.withValues(alpha: 0.35)
              : colors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 25,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deductions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Pre-tax and post-tax contributions',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hasDeductions
                      ? colors.primaryContainer
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasDeductions ? 'Added' : 'Optional',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: hasDeductions
                        ? colors.onPrimaryContainer
                        : colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Summary panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hasDeductions
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
                  size: 20,
                  color: hasDeductions
                      ? colors.primary
                      : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasDeductions
                            ? '${calc.userDeductions.length} deduction'
                                  '${calc.userDeductions.length == 1 ? '' : 's'} configured'
                            : 'Customize your deductions',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasDeductions
                            ? 'Manage contributions that affect your paycheck estimate.'
                            : 'Add 401(k), HSA, insurance premiums, or other deductions.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Pre-tax deductions
          if (preTax.isNotEmpty) ...[
            const SizedBox(height: 20),
            _DeductionGroupHeader(
              title: 'PRE-TAX',
              subtitle: '${preTax.length} item${preTax.length == 1 ? '' : 's'}',
              color: colors.tertiary,
              icon: Icons.savings_outlined,
            ),
            const SizedBox(height: 10),
            for (final deduction in preTax)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _UserDeductionTile(
                  deduction: deduction,
                  onEdit: () => showDeductionSheet(context, calc, deduction),
                  onDelete: () => calc.removeDeduction(deduction.id),
                ),
              ),
          ],

          // Post-tax deductions
          if (postTax.isNotEmpty) ...[
            const SizedBox(height: 12),
            _DeductionGroupHeader(
              title: 'POST-TAX',
              subtitle:
                  '${postTax.length} item${postTax.length == 1 ? '' : 's'}',
              color: colors.secondary,
              icon: Icons.receipt_long_outlined,
            ),
            const SizedBox(height: 10),
            for (final deduction in postTax)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _UserDeductionTile(
                  deduction: deduction,
                  onEdit: () => showDeductionSheet(context, calc, deduction),
                  onDelete: () => calc.removeDeduction(deduction.id),
                ),
              ),
          ],

          const SizedBox(height: 6),

          // Add button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: hasDeductions
                ? OutlinedButton.icon(
                    onPressed: () => showDeductionSheet(context, calc, null),
                    icon: const Icon(Icons.add_rounded, size: 21),
                    label: const Text('Add another deduction'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  )
                : FilledButton.icon(
                    onPressed: () => showDeductionSheet(context, calc, null),
                    icon: const Icon(Icons.add_rounded, size: 21),
                    label: const Text('Add deduction'),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DeductionGroupHeader extends StatelessWidget {
  const _DeductionGroupHeader({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 7),
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const Spacer(),
        Text(
          subtitle,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _UserDeductionTile extends StatelessWidget {
  const _UserDeductionTile({
    required this.deduction,
    required this.onEdit,
    required this.onDelete,
  });

  final UserDeduction deduction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final valueLabel = deduction.isPercentage
        ? '${fmtPct(deduction.value)}% of gross'
        : fmtPct(deduction.value);

    final kindLabel = _deductionKindLabel(deduction.kind);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.payments_outlined,
              size: 21,
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deduction.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  kindLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  valueLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Deduction options',
            icon: Icon(Icons.more_vert_rounded, color: colors.onSurfaceVariant),
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 19),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 19),
                    SizedBox(width: 10),
                    Text('Remove'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _deductionKindLabel(DeductionKind kind) {
    switch (kind) {
      case DeductionKind.traditional401k:
        return 'Traditional 401(k)';
      case DeductionKind.roth401k:
        return 'Roth 401(k)';
      case DeductionKind.hsa:
        return 'Health Savings Account';
      case DeductionKind.insurancePremium:
        return 'Insurance premium';
      case DeductionKind.other:
        return 'Other deduction';
    }
  }
}

String fmtPct(double value) {
  final s = value % 1 == 0
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
  return s;
}

void showDeductionSheet(
  BuildContext context,
  CalculatorProvider calc,
  UserDeduction? existing,
) {
  final nameController = TextEditingController(text: existing?.name);
  final valueController = TextEditingController(
    text: existing == null ? '' : existing.value.toString(),
  );
  var isPercentage = existing?.isPercentage ?? false;
  var preTax = existing?.preTax ?? true;
  var kind = existing?.kind ?? DeductionKind.other;
  final formKey = GlobalKey<FormState>();

  showFormSheet(
    context,
    title: existing == null ? 'Add deduction' : 'Edit deduction',
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Name (e.g. Traditional 401k)',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 12),
            sheetAmountField(
              controller: valueController,
              hintText: isPercentage ? 'Percent of gross' : 'Amount per period',
              validator: (v) {
                final parsed = double.tryParse(v ?? '');
                if (parsed == null || parsed <= 0) {
                  return isPercentage
                      ? 'Enter a percentage of gross'
                      : 'Enter an amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => setSheetState(() => isPercentage = !isPercentage),
              child: Row(
                children: [
                  const Expanded(child: Text('Percentage of gross')),
                  Switch(
                    value: isPercentage,
                    onChanged: (v) => setSheetState(() => isPercentage = v),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => setSheetState(() => preTax = !preTax),
              child: Row(
                children: [
                  const Expanded(child: Text('Pre-tax')),
                  Switch(
                    value: preTax,
                    onChanged: (v) => setSheetState(() => preTax = v),
                  ),
                ],
              ),
            ),
            DropdownButtonFormField<DeductionKind>(
              initialValue: kind,
              items: const [
                DropdownMenuItem(
                  value: DeductionKind.traditional401k,
                  child: Text('Traditional 401(k)'),
                ),
                DropdownMenuItem(
                  value: DeductionKind.roth401k,
                  child: Text('Roth 401(k)'),
                ),
                DropdownMenuItem(value: DeductionKind.hsa, child: Text('HSA')),
                DropdownMenuItem(
                  value: DeductionKind.insurancePremium,
                  child: Text('Insurance premium'),
                ),
                DropdownMenuItem(
                  value: DeductionKind.other,
                  child: Text('Other'),
                ),
              ],
              onChanged: (v) =>
                  setSheetState(() => kind = v ?? DeductionKind.other),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Type',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                final deduction = UserDeduction(
                  id: existing?.id ?? UniqueKey().toString(),
                  name: nameController.text.trim(),
                  value: double.tryParse(valueController.text.trim()) ?? 0,
                  isPercentage: isPercentage,
                  preTax: preTax,
                  kind: kind,
                );
                if (existing == null) {
                  calc.addDeduction(deduction);
                } else {
                  calc.editDeduction(existing.id, deduction);
                }
                Navigator.pop(sheetContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    ),
  );
}

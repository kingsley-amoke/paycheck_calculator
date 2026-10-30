// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../../../data/models/calculation_profile.dart';
// import '../../provider/calculator_provider.dart';
// import 'section_scaffold.dart';

// class ExtraIncomeSection extends StatelessWidget {
//   const ExtraIncomeSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final calc = context.watch<CalculatorProvider>();

//     return SectionCard(
//       label: 'ADDITIONAL INCOME',
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (calc.incomeItems.isEmpty)
//             const Text(
//               'Bonuses, commissions, tips, other taxable income.',
//               style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
//             ),
//           for (final item in calc.incomeItems)
//             Padding(
//               padding: const EdgeInsets.only(top: 6),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       item.name,
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                   Text(
//                     item.occurrence == ExtraIncomeOccurrence.oncePerYear
//                         ? 'once / year'
//                         : 'per paycheck',
//                     style: const TextStyle(
//                       fontSize: 11,
//                       color: Color(0xFF6B7280),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.delete_outline, size: 20),
//                     onPressed: () => calc.removeIncomeItem(item.id),
//                   ),
//                 ],
//               ),
//             ),
//           addRowButton(() => showIncomeItemSheet(context, calc, null)),
//         ],
//       ),
//     );
//   }
// }

// void showIncomeItemSheet(
//   BuildContext context,
//   CalculatorProvider calc,
//   ExtraIncomeItem? existing,
// ) {
//   final nameController = TextEditingController(text: existing?.name);
//   final amountController = TextEditingController(
//     text: existing == null ? '' : existing.amount.toString(),
//   );
//   var oncePerYear = existing?.occurrence == ExtraIncomeOccurrence.oncePerYear;
//   final formKey = GlobalKey<FormState>();

//   showFormSheet(
//     context,
//     title: existing == null ? 'Add income item' : 'Edit income item',
//     builder: (sheetContext) => StatefulBuilder(
//       builder: (sheetContext, setSheetState) => Form(
//         key: formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextFormField(
//               controller: nameController,
//               textCapitalization: TextCapitalization.words,
//               decoration: const InputDecoration(
//                 hintText: 'Name (e.g. Quarterly bonus)',
//                 border: OutlineInputBorder(),
//               ),
//               validator: (v) =>
//                   (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
//             ),
//             const SizedBox(height: 12),
//             sheetAmountField(
//               controller: amountController,
//               hintText: 'Amount ${oncePerYear ? 'per year' : 'per paycheck'}',
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Expanded(child: Text('Paid once per year')),
//                 Switch(
//                   value: oncePerYear,
//                   onChanged: (v) => setSheetState(() => oncePerYear = v),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             FilledButton(
//               onPressed: () {
//                 if (formKey.currentState?.validate() != true) return;
//                 final amount =
//                     double.tryParse(amountController.text.trim()) ?? 0;
//                 final item = ExtraIncomeItem(
//                   id: existing?.id ?? UniqueKey().toString(),
//                   name: nameController.text.trim(),
//                   amount: amount,
//                   occurrence: oncePerYear
//                       ? ExtraIncomeOccurrence.oncePerYear
//                       : ExtraIncomeOccurrence.everyPaycheck,
//                 );
//                 if (existing == null) {
//                   calc.addIncomeItem(item);
//                 } else {
//                   calc.editIncomeItem(existing.id, item);
//                 }
//                 Navigator.pop(sheetContext);
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/calculation_profile.dart';
import '../../provider/calculator_provider.dart';
import 'section_scaffold.dart';

class ExtraIncomeSection extends StatelessWidget {
  const ExtraIncomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final items = calc.incomeItems;
    final hasIncome = items.isNotEmpty;

    final summary = hasIncome
        ? '${items.length} income ${items.length == 1 ? 'item' : 'items'} added'
        : 'Bonuses, commissions, tips, and other taxable income.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasIncome
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.35)
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IncomeHeader(hasIncome: hasIncome),
          const SizedBox(height: 18),

          // Summary panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hasIncome
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
                  size: 20,
                  color: hasIncome
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: hasIncome
                              ? FontWeight.w600
                              : FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                      if (!hasIncome) ...[
                        const SizedBox(height: 5),
                        Text(
                          'Add extra income to include it in your paycheck estimate.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Existing income items
          if (hasIncome) ...[
            const SizedBox(height: 14),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _IncomeItemTile(
                  name: item.name,
                  amount: item.amount,
                  occurrence: item.occurrence,
                  onEdit: () => showIncomeItemSheet(context, calc, item),
                  onDelete: () => calc.removeIncomeItem(item.id),
                ),
              ),
            ),
          ],

          const SizedBox(height: 6),

          // Add income button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: hasIncome
                ? OutlinedButton.icon(
                    onPressed: () => showIncomeItemSheet(context, calc, null),
                    icon: const Icon(Icons.add_rounded, size: 21),
                    label: const Text('Add another income'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  )
                : FilledButton.icon(
                    onPressed: () => showIncomeItemSheet(context, calc, null),
                    icon: const Icon(Icons.add_rounded, size: 21),
                    label: const Text('Add income'),
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

class _IncomeHeader extends StatelessWidget {
  const _IncomeHeader({required this.hasIncome});

  final bool hasIncome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.trending_up_rounded,
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
                'Additional income',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Bonuses, tips & commissions',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: hasIncome
                ? colors.primaryContainer
                : colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            hasIncome ? 'Added' : 'Optional',
            style: theme.textTheme.labelSmall?.copyWith(
              color: hasIncome
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _IncomeItemTile extends StatelessWidget {
  const _IncomeItemTile({
    required this.name,
    required this.amount,
    required this.occurrence,
    required this.onEdit,
    required this.onDelete,
  });

  final String name;
  final double amount;
  final ExtraIncomeOccurrence occurrence;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final frequency = occurrence == ExtraIncomeOccurrence.oncePerYear
        ? 'Paid once per year'
        : 'Per paycheck';

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
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.payments_outlined,
              color: colors.onSecondaryContainer,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  frequency,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  amount.toStringAsFixed(2),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Income options',
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
}

// Existing bottom-sheet logic retained.
void showIncomeItemSheet(
  BuildContext context,
  CalculatorProvider calc,
  ExtraIncomeItem? existing,
) {
  final nameController = TextEditingController(text: existing?.name);
  final amountController = TextEditingController(
    text: existing == null ? '' : existing.amount.toString(),
  );

  var oncePerYear = existing?.occurrence == ExtraIncomeOccurrence.oncePerYear;

  final formKey = GlobalKey<FormState>();

  showFormSheet(
    context,
    title: existing == null ? 'Add income item' : 'Edit income item',
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
                hintText: 'Name (e.g. Quarterly bonus)',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 12),
            sheetAmountField(
              controller: amountController,
              hintText: 'Amount ${oncePerYear ? 'per year' : 'per paycheck'}',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: Text('Paid once per year')),
                Switch(
                  value: oncePerYear,
                  onChanged: (v) => setSheetState(() => oncePerYear = v),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;

                final amount =
                    double.tryParse(amountController.text.trim()) ?? 0;

                final item = ExtraIncomeItem(
                  id: existing?.id ?? UniqueKey().toString(),
                  name: nameController.text.trim(),
                  amount: amount,
                  occurrence: oncePerYear
                      ? ExtraIncomeOccurrence.oncePerYear
                      : ExtraIncomeOccurrence.everyPaycheck,
                );

                if (existing == null) {
                  calc.addIncomeItem(item);
                } else {
                  calc.editIncomeItem(existing.id, item);
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

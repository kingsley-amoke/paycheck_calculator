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

    return SectionCard(
      label: 'ADDITIONAL INCOME',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (calc.incomeItems.isEmpty)
            const Text(
              'Bonuses, commissions, tips, other taxable income.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          for (final item in calc.incomeItems)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    item.occurrence == ExtraIncomeOccurrence.oncePerYear
                        ? 'once / year'
                        : 'per paycheck',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => calc.removeIncomeItem(item.id),
                  ),
                ],
              ),
            ),
          addRowButton(
            () => showIncomeItemSheet(context, calc, null),
          ),
        ],
      ),
    );
  }
}

void showIncomeItemSheet(
  BuildContext context,
  CalculatorProvider calc,
  ExtraIncomeItem? existing,
) {
  final nameController = TextEditingController(text: existing?.name);
  final amountController = TextEditingController(
    text: existing == null ? '' : existing.amount.toString(),
  );
  var oncePerYear =
      existing?.occurrence == ExtraIncomeOccurrence.oncePerYear;
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
              hintText:
                  'Amount ${oncePerYear ? 'per year' : 'per paycheck'}',
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

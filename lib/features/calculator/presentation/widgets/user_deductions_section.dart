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
    final preTax = calc.userDeductions.where((d) => d.preTax).toList();
    final postTax = calc.userDeductions.where((d) => !d.preTax).toList();

    return SectionCard(
      label: 'DEDUCTIONS',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (calc.userDeductions.isEmpty)
            const Text(
              '401(k), HSA, insurance premiums, other deductions.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          if (preTax.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Text(
              'PRE-TAX',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: Color(0xFF16A34A),
              ),
            ),
            for (final d in preTax) _deductionRow(calc, d),
          ],
          if (postTax.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Text(
              'POST-TAX',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: Color(0xFF6B7280),
              ),
            ),
            for (final d in postTax) _deductionRow(calc, d),
          ],
          addRowButton(() => showDeductionSheet(context, calc, null)),
        ],
      ),
    );
  }

  Widget _deductionRow(CalculatorProvider calc, UserDeduction d) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              d.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            d.isPercentage ? '${fmtPct(d.value)}% of gross' : fmtPct(d.value),
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => calc.removeDeduction(d.id),
          ),
        ],
      ),
    );
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

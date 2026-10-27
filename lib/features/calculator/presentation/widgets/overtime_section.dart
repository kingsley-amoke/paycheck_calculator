import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/calculation_profile.dart';
import '../../../../domain/usecases/profile_inputs.dart';
import '../../provider/calculator_provider.dart';
import 'section_scaffold.dart';

/// Overtime input: hours per paycheck plus either an explicit OT rate OR
/// a multiplier of the regular hourly rate — never both applied.
class OvertimeSection extends StatelessWidget {
  const OvertimeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final hasOvertime = calc.overtimeHoursPerPeriod > 0;

    String summary = 'Overtime hours per paycheck. ';
    if (hasOvertime) {
      final rate = resolvedRateFor(
        hourlyRate: calc.hourlyRate,
        overtime: OvertimeInput(
          hoursPerPeriod: calc.overtimeHoursPerPeriod,
          explicitRate: calc.overtimeRate,
          multiplier: calc.overtimeMultiplier,
        ),
      );
      final basis = calc.overtimeRate != null
          ? 'explicit rate'
          : '${calc.overtimeMultiplier} × hourly rate';
      summary =
          '${calc.overtimeHoursPerPeriod.toStringAsFixed(0)} h @ '
          '${rate.toStringAsFixed(2)}/h ($basis).';
    } else {
      summary += calc.hourlyRate > 0
          ? 'No overtime entered.'
          : 'Requires an hourly rate or an explicit OT rate.';
    }

    return SectionCard(
      label: 'OVERTIME',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          addRowButton(() => showOvertimeSheet(context, calc)),
        ],
      ),
    );
  }
}

void showOvertimeSheet(BuildContext context, CalculatorProvider calc) {
  final hoursController = TextEditingController(
    text: calc.overtimeHoursPerPeriod > 0
        ? calc.overtimeHoursPerPeriod.toStringAsFixed(0)
        : '',
  );
  final rateController = TextEditingController(
    text: calc.overtimeRate?.toString() ?? '',
  );
  final multiplierController = TextEditingController(
    text: calc.overtimeMultiplier?.toString() ?? '',
  );
  var useMultiplier = calc.overtimeMultiplier != null;
  var useExplicitRate = !useMultiplier;
  final formKey = GlobalKey<FormState>();

  showFormSheet(
    context,
    title: 'Overtime',
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Overtime hours per paycheck',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final parsed = double.tryParse(v ?? '');
                if (parsed == null || parsed <= 0) {
                  return 'Enter hours worked';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Rate')),
                ButtonSegment(value: false, label: Text('× hourly')),
              ],
              selected: {useMultiplier},
              onSelectionChanged: (selection) => setSheetState(() {
                useMultiplier = selection.first;
                useExplicitRate = !useMultiplier;
              }),
            ),
            const SizedBox(height: 12),
            if (useMultiplier)
              sheetAmountField(
                controller: multiplierController,
                hintText: 'Multiplier (e.g. 1.5)',
                validator: (v) {
                  final parsed = double.tryParse(v ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a multiplier';
                  }
                  if (calc.hourlyRate <= 0) {
                    return 'Set an hourly rate first';
                  }
                  return null;
                },
              )
            else
              sheetAmountField(
                controller: rateController,
                hintText: 'Overtime hourly rate',
                validator: (v) {
                  final parsed = double.tryParse(v ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter an hourly rate';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 8),
            if (calc.overtimeHoursPerPeriod > 0)
              TextButton(
                onPressed: () {
                  calc.clearOvertime();
                  Navigator.pop(sheetContext);
                },
                child: const Text('Remove overtime'),
              ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                calc.setOvertime(
                  hoursPerPeriod:
                      double.tryParse(hoursController.text.trim()) ?? 0,
                  rate: useExplicitRate
                      ? double.tryParse(rateController.text.trim())
                      : null,
                  multiplier: useMultiplier
                      ? double.tryParse(multiplierController.text.trim())
                      : null,
                );
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

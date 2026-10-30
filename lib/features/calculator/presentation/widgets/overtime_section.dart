import 'package:flutter/material.dart';
import 'package:paycheck_calculator/data/models/calculation_profile.dart';
import 'package:paycheck_calculator/domain/usecases/profile_inputs.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/section_scaffold.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:provider/provider.dart';

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

class OvertimeSection extends StatelessWidget {
  const OvertimeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final hasOvertime = calc.overtimeHoursPerPeriod > 0;

    String summary;

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
          ? 'Custom rate'
          : '${calc.overtimeMultiplier}× hourly rate';

      summary =
          '${calc.overtimeHoursPerPeriod.toStringAsFixed(0)} hours per '
          'paycheck at ${rate.toStringAsFixed(2)}/h';

      return _overtimeCard(
        context: context,
        calc: calc,
        hasOvertime: true,
        title: 'Overtime',
        summary: summary,
        detail: basis,
      );
    }

    summary = calc.hourlyRate > 0
        ? 'Add extra hours to include overtime in your estimate.'
        : 'Enter an hourly rate or use a custom overtime rate.';

    return _overtimeCard(
      context: context,
      calc: calc,
      hasOvertime: false,
      title: 'Overtime',
      summary: summary,
      detail: null,
    );
  }

  Widget _overtimeCard({
    required BuildContext context,
    required CalculatorProvider calc,
    required bool hasOvertime,
    required String title,
    required String summary,
    required String? detail,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasOvertime
              ? colors.primary.withValues(alpha: 0.35)
              : colors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  Icons.more_time_rounded,
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
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Extra hours worked',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hasOvertime
                      ? colors.primaryContainer
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasOvertime ? 'Added' : 'Optional',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: hasOvertime
                        ? colors.onPrimaryContainer
                        : colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
                  hasOvertime
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
                  size: 20,
                  color: hasOvertime ? colors.primary : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: hasOvertime
                              ? FontWeight.w600
                              : FontWeight.w400,
                          height: 1.4,
                          color: colors.onSurface,
                        ),
                      ),
                      if (detail != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          detail,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: hasOvertime
                ? OutlinedButton.icon(
                    onPressed: () => showOvertimeSheet(context, calc),
                    icon: const Icon(Icons.edit_outlined, size: 19),
                    label: const Text('Edit overtime'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  )
                : FilledButton.icon(
                    onPressed: () => showOvertimeSheet(context, calc),
                    icon: const Icon(Icons.add_rounded, size: 21),
                    label: const Text('Add overtime'),
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

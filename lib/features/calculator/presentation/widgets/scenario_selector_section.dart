import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/widgets/country_label.dart';
import 'package:paycheck_calculator/core/widgets/filing_status_label.dart';
import 'package:paycheck_calculator/core/widgets/pay_frequency_label.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/section_header.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/styled_dropdown.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/styled_region_dropdown.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/styled_text_field.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/enums.dart';

class ScenarioSelectorSection extends StatelessWidget {
  const ScenarioSelectorSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<CalculatorProvider>();
    final regions = provider.taxConfig?.regions?.items ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Country + Income + Frequency inputs ──
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Parameters'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StyledDropdown<Country>(
                      label: 'Country',
                      value: provider.country,
                      items: Country.values,
                      itemLabel: (c) => countryLabel(c),
                      onChanged: (c) {
                        provider.setCountry(c);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StyledDropdown<PayFrequency>(
                      label: 'Frequency',
                      value: provider.frequency,
                      items: PayFrequency.values,
                      itemLabel: (f) => payFrequencyLabel(f),
                      onChanged: (f) {
                        provider.setFrequency(f);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StyledTextField(
                label: 'Income',
                initialValue: provider.income.toStringAsFixed(0),
                onChanged: (v) {
                  provider.setIncome(double.tryParse(v) ?? 0);
                },
              ),
              if (provider.taxConfig?.filingStatuses != null &&
                  provider.taxConfig?.regions != null) ...[
                const SizedBox(height: 12),
                StyledDropdown<FilingStatus>(
                  label: 'FILING STATUS',
                  value: provider.filingStatus,
                  items: FilingStatus.values,
                  itemLabel: (f) => filingStatusToLabel(f),
                  onChanged: (f) {
                    provider.setFilingStatus(f);
                  },
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Region dropdowns ──
        if (regions.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Select Regions to Compare'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StyledRegionDropdown(
                        label: '',
                        value: provider.regionA,
                        regions: regions,
                        excludeValue: provider.regionB,
                        onChanged: (val) {
                          provider.setRegionA(val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StyledRegionDropdown(
                        label: '',
                        value: provider.regionB,
                        regions: regions,
                        excludeValue: provider.regionA,
                        onChanged: (val) {
                          provider.setRegionB(val);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

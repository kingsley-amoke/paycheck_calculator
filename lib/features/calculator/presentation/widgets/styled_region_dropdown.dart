import 'package:flutter/material.dart';
import 'package:paycheck_calculator/data/models/region_tax.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/section_header.dart';

class StyledRegionDropdown extends StatelessWidget {
  final String label;
  final RegionTax? value;
  final List regions;
  final RegionTax? excludeValue;
  final ValueChanged<RegionTax> onChanged;

  const StyledRegionDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.regions,
    required this.onChanged,
    this.excludeValue,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final available = regions.where((r) => r != excludeValue).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: value != null
                ? cs.primary.withValues(alpha: 0.06)
                : cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value != null
                  ? cs.primary.withValues(alpha: 0.4)
                  : cs.outlineVariant,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<RegionTax>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Select region',
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              borderRadius: BorderRadius.circular(12),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: cs.onSurface,
              ),
              items: available
                  .map<DropdownMenuItem<RegionTax>>(
                    (r) => DropdownMenuItem(
                      value: r,
                      child: Text(r.name as String),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                onChanged(v!);
              },
            ),
          ),
        ),
      ],
    );
  }
}

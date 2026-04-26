import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/section_header.dart';

class StyledDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onChanged;

  const StyledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: cs.onSurface,
              ),
              items: items
                  .map(
                    (i) =>
                        DropdownMenuItem(value: i, child: Text(itemLabel(i))),
                  )
                  .toList(),
              onChanged: (v) => onChanged(v as T),
            ),
          ),
        ),
      ],
    );
  }
}

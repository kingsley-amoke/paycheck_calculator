// import 'package:flutter/material.dart';

// /// Shared card + sheet scaffolding for the calculator input sections.

// class SectionCard extends StatelessWidget {
//   final String label;
//   final Widget child;

//   const SectionCard({super.key, required this.label, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(top: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.8,
//                     color: Color(0xFF6B7280),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           child,
//         ],
//       ),
//     );
//   }
// }

// /// Opens a titled form bottom sheet; returns when dismissed.
// Future<void> showFormSheet(
//   BuildContext context, {
//   required String title,
//   required WidgetBuilder builder,
// }) {
//   return showModalBottomSheet<void>(
//     context: context,
//     isScrollControlled: true,
//     builder: (sheetContext) => Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
//       ),
//       child: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               // Builder so the form can read its own state.
//               Builder(builder: builder),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// Row addRowButton(VoidCallback onAdd) {
//   return Row(
//     children: [
//       const Spacer(),
//       TextButton.icon(
//         onPressed: onAdd,
//         icon: const Icon(Icons.add, size: 18),
//         label: const Text('ADD'),
//       ),
//     ],
//   );
// }

// TextFormField sheetAmountField({
//   required TextEditingController controller,
//   required String hintText,
//   String? Function(String?)? validator,
// }) {
//   return TextFormField(
//     controller: controller,
//     keyboardType: const TextInputType.numberWithOptions(decimal: true),
//     decoration: InputDecoration(
//       hintText: hintText,
//       border: const OutlineInputBorder(),
//     ),
//     validator:
//         validator ??
//         (v) {
//           if (double.tryParse(v ?? '') == null) return 'Enter a number';
//           return null;
//         },
//   );
// }

import 'package:flutter/material.dart';

/// Shared styling for calculator adjustment sections.
class SectionCard extends StatelessWidget {
  final String label;
  final Widget child;
  final String? subtitle;
  final Widget? trailing;

  const SectionCard({
    super.key,
    required this.label,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Opens a scrollable form bottom sheet that accommodates the keyboard.
Future<void> showFormSheet(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;

      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              Builder(builder: builder),
            ],
          ),
        ),
      );
    },
  );
}

/// Backward-compatible add button, with an optional descriptive label.
Row addRowButton(VoidCallback onAdd, {String label = 'Add item'}) {
  return Row(
    children: [
      const Spacer(),
      TextButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(label),
      ),
    ],
  );
}

TextFormField sheetAmountField({
  required TextEditingController controller,
  required String hintText,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    validator:
        validator ??
        (value) {
          if (double.tryParse(value?.trim() ?? '') == null) {
            return 'Enter a valid number';
          }
          return null;
        },
  );
}

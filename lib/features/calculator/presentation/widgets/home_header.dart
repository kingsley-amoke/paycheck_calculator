// import 'package:flutter/material.dart';

// class HomeHeader extends StatelessWidget {
//   const HomeHeader({
//     super.key,
//     required this.onSave,
//     required this.onSavedCalculations,
//     required this.onCompare,
//     required this.onAnnualProjection,
//     required this.hasUnsavedChanges,
//   });

//   final VoidCallback onSave;
//   final VoidCallback onSavedCalculations;
//   final VoidCallback onCompare;
//   final VoidCallback onAnnualProjection;
//   final bool hasUnsavedChanges;

//   @override
//   Widget build(BuildContext context) {
//     return Builder(
//       builder: (context) {
//         final theme = Theme.of(context);
//         final colors = theme.colorScheme;

//         return Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Paycheck Calculator',
//                     style: theme.textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: -0.7,
//                       color: colors.onSurface,
//                     ),
//                   ),
//                   // const SizedBox(height: 3),
//                   // Text(
//                   //   'Estimate your take-home pay',
//                   //   style: theme.textTheme.bodySmall?.copyWith(
//                   //     color: colors.onSurfaceVariant,
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//             if (hasUnsavedChanges)
//               Padding(
//                 padding: const EdgeInsets.only(right: 4),
//                 child: Tooltip(
//                   message: 'You have unsaved changes',
//                   child: Icon(Icons.circle, size: 8, color: colors.tertiary),
//                 ),
//               ),
//             PopupMenuButton<String>(
//               tooltip: 'Calculator actions',
//               icon: const Icon(Icons.more_vert_rounded),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               onSelected: (value) {
//                 switch (value) {
//                   case 'save':
//                     onSave();
//                   case 'saved':
//                     onSavedCalculations();
//                   case 'compare':
//                     onCompare();
//                   case 'projection':
//                     onAnnualProjection();
//                 }
//               },
//               itemBuilder: (context) => const [
//                 PopupMenuItem(
//                   value: 'save',
//                   child: ListTile(
//                     leading: Icon(Icons.bookmark_add_outlined),
//                     title: Text('Save calculation'),
//                     contentPadding: EdgeInsets.zero,
//                   ),
//                 ),
//                 PopupMenuItem(
//                   value: 'saved',
//                   child: ListTile(
//                     leading: Icon(Icons.history_rounded),
//                     title: Text('Saved calculations'),
//                     contentPadding: EdgeInsets.zero,
//                   ),
//                 ),
//                 // PopupMenuDivider(),
//                 // PopupMenuItem(
//                 //   value: 'compare',
//                 //   child: ListTile(
//                 //     leading: Icon(Icons.compare_arrows_rounded),
//                 //     title: Text('Compare calculations'),
//                 //     contentPadding: EdgeInsets.zero,
//                 //   ),
//                 // ),
//                 // PopupMenuItem(
//                 //   value: 'projection',
//                 //   child: ListTile(
//                 //     leading: Icon(Icons.trending_up_rounded),
//                 //     title: Text('Annual projection'),
//                 //     contentPadding: EdgeInsets.zero,
//                 //   ),
//                 // ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onSave,
    required this.onSavedCalculations,
    required this.onCompare,
    required this.onAnnualProjection,
    required this.hasUnsavedChanges,
  });

  final VoidCallback onSave;
  final VoidCallback onSavedCalculations;
  final VoidCallback onCompare;
  final VoidCallback onAnnualProjection;
  final bool hasUnsavedChanges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'Paycheck Calculator',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (hasUnsavedChanges)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Tooltip(
                    message: 'You have unsaved changes',
                    child: Icon(Icons.circle, size: 8, color: colors.tertiary),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Save Profile
        _HeaderActionButton(
          icon: Icons.bookmark_add_outlined,
          label: 'Save',
          tooltip: 'Save calculation profile',
          onPressed: onSave,
        ),

        const SizedBox(width: 12),

        // History
        _HeaderActionButton(
          icon: Icons.history_rounded,
          label: 'History',
          tooltip: 'View saved calculations',
          onPressed: onSavedCalculations,
        ),
      ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: colors.primary),
            const SizedBox(height: 3),
            // Text(
            //   label,
            //   style: theme.textTheme.labelSmall?.copyWith(
            //     fontWeight: FontWeight.w600,
            //     color: colors.onSurface,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

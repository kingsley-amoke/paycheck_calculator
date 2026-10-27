import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/calculation_profile.dart';
import '../../../../domain/entities/paycheck_result.dart';
import '../../provider/calculator_provider.dart';
import '../../provider/comparison_provider.dart';
import '../../provider/profile_provider.dart';
import '../../../../core/widgets/pay_frequency_label.dart';
import '../widgets/save_profile_sheet.dart';

/// Manage saved calculation profiles: open, activate, duplicate, rename,
/// delete. Read-only on the working calculation except through explicit
/// activation.
class SavedCalculationsScreen extends StatelessWidget {
  const SavedCalculationsScreen({super.key});

  void _saveDialog(BuildContext context) => showSaveProfileSheet(context);

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Saved Calculations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Save current calculation',
            onPressed: () => _saveDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: profiles.isLoading
            ? const Center(child: CircularProgressIndicator())
            : profiles.profiles.isEmpty
                ? _emptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: profiles.profiles.length,
                    itemBuilder: (context, index) => ProfileCard(
                      profile: profiles.profiles[index],
                    ),
                  ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bookmark_border, size: 44, color: AppColors.textLight),
          const SizedBox(height: 8),
          const Text(
            'No saved calculations yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _saveDialog(context),
            child: const Text('Save your current calculation'),
          ),
        ],
      ),
    );
  }
}

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key, required this.profile});

  final CalculationProfile profile;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  late final Future<PaycheckResult> _resultFuture;

  CalculationProfile get profile => widget.profile;

  @override
  void initState() {
    super.initState();
    _resultFuture = calculateProfileResult(widget.profile);
  }

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ProfileProvider>();
    final country = context.watch<CalculatorProvider>().country;
    final profile = widget.profile;
    final isActive = profiles.activeProfileId == profile.id;

    return FutureBuilder<PaycheckResult>(
      future: _resultFuture,
      builder: (context, snapshot) {
        final result = snapshot.data;
        final grossPerPeriod = result == null
            ? ''
            : CurrencyFormatter.format(
                profile.income, country,
              );
        final netPerPeriod = result == null
            ? ''
            : CurrencyFormatter.format(
                result.netIncome,
                country,
              );

        return Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.divider,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${payFrequencyLabel(profile.payFrequency)} · '
                      '${grossPerPeriod} gross',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result == null
                          ? 'Calculating…'
                          : '$netPerPeriod take-home / period',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: result == null
                            ? AppColors.textLight
                            : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: result == null
                    ? null
                    : () => _showActionsSheet(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showActionsSheet(BuildContext context) {
    final profiles = context.read<ProfileProvider>();

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Open'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await profiles.activate(profile.id);
                if (context.mounted) Navigator.pop(context);
              },
              subtitle:
                  const Text('Load into the working calculation and edit it'),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Activate'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await profiles.activate(profile.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await profiles.duplicate(profile.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(sheetContext);
                _renameDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(sheetContext);
                _deleteConfirm(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _renameDialog(BuildContext context) {
    final controller = TextEditingController(text: profile.name);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename calculation'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              Navigator.pop(dialogContext);
              if (name.isNotEmpty) {
                await context.read<ProfileProvider>().rename(profile.id, name);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteConfirm(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete calculation'),
        content: Text(
          'Delete \'${profile.name}\'? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<ProfileProvider>().delete(profile.id);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

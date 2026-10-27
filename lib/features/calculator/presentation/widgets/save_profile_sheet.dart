import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../features/subscription/domain/feature_access.dart';
import '../../../../features/subscription/provider/subscription_provider.dart';
import '../../provider/profile_provider.dart';

/// Save-the-current-calculation sheet. Named add entry point for new
/// profiles; enforces the centralized free-tier limit.
void showSaveProfileSheet(BuildContext context) {
  final nameController = TextEditingController();
  final profileProvider = context.read<ProfileProvider>();

  bool hasAccess = false;
  try {
    hasAccess = context.read<SubscriptionProvider>().hasAccess;
  } on ProviderNotFoundException {
    // Environments without an active subscription (also the free default).
    hasAccess = false;
  }

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Save this calculation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (!FeatureAccess.canAddProfile(
              profileProvider.profiles.length,
              hasAccess,
            ))
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Free plan stores 1 saved calculation. Upgrade for unlimited profiles.',
                  style: TextStyle(fontSize: 13, color: Color(0xFFBA1A1A)),
                ),
              ),
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText:
                    'Name (e.g. Main Job ${profileProvider.profiles.length + 1})',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                debugPrint('DBG save pressed canAdd check');
                final canAdd = FeatureAccess.canAddProfile(
                  profileProvider.profiles.length,
                  hasAccess,
                );
                if (!canAdd) return; // upgrade prompt row explains the limit
                final name = nameController.text.trim().isEmpty
                    ? 'My Calculation ${profileProvider.profiles.length + 1}'
                    : nameController.text.trim();
                debugPrint('DBG about to save');
                await profileProvider.saveCurrentAs(name);
                debugPrint('DBG saved');
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    ),
  );
}

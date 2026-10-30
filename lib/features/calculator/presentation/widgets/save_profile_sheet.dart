import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/calculator/provider/profile_provider.dart';
import 'package:paycheck_calculator/features/paywall/subscription_plans_screen.dart';
import 'package:paycheck_calculator/features/subscription/domain/feature_access.dart';
import 'package:paycheck_calculator/features/subscription/provider/subscription_provider.dart';
import 'package:provider/provider.dart';

void showSaveProfileSheet(BuildContext context) {
  // final nameController = TextEditingController();
  final profileProvider = context.read<ProfileProvider>();

  bool hasAccess = false;
  try {
    hasAccess = context.read<SubscriptionProvider>().hasAccess;
  } on ProviderNotFoundException {
    // Environments without an active subscription default to free access.
    hasAccess = false;
  }

  // final canAddProfile = FeatureAccess.canAddProfile(
  //   profileProvider.profiles.length,
  //   hasAccess,
  // );
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return SaveProfileSheet(
        profileProvider: profileProvider,
        hasAccess: hasAccess,
      );
    },
  );
}

class SaveProfileSheet extends StatefulWidget {
  const SaveProfileSheet({
    super.key,
    required this.profileProvider,
    required this.hasAccess,
  });

  final ProfileProvider profileProvider;
  final bool hasAccess;

  @override
  State<SaveProfileSheet> createState() => SaveProfileSheetState();
}

class SaveProfileSheetState extends State<SaveProfileSheet> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = widget.profileProvider;
    final hasAccess = widget.hasAccess;
    final canAdd = FeatureAccess.canAddProfile(
      profileProvider.profiles.length,
      hasAccess,
    );

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.bookmark_add_outlined,
                    size: 30,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Save calculation',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Give this paycheck scenario a name so you can find it later.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText:
                      'e.g. Main Job ${profileProvider.profiles.length + 1}',
                  prefixIcon: const Icon(Icons.edit_outlined),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!canAdd)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Free plan stores 1 saved calculation. '
                    'Upgrade to save additional profiles.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onErrorContainer,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: () async {
                    final allowed = FeatureAccess.canAddProfile(
                      profileProvider.profiles.length,
                      hasAccess,
                    );

                    if (!allowed) {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SubscriptionPlansScreen(),
                        ),
                      );
                      return;
                    }

                    final enteredName = _nameController.text.trim();
                    final name = enteredName.isEmpty
                        ? 'My Calculation '
                              '${profileProvider.profiles.length + 1}'
                        : enteredName;

                    await profileProvider.saveCurrentAs(name);

                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    canAdd
                        ? Icons.bookmark_add_outlined
                        : Icons.lock_open_outlined,
                  ),
                  label: Text(canAdd ? 'Save calculation' : 'Upgrade to save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

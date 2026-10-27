//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paycheck_calculator/core/utils/open_url.dart';
import 'package:paycheck_calculator/features/paywall/subscription_plans_screen.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';

import 'package:paycheck_calculator/core/constants/app_colors.dart';
import 'package:paycheck_calculator/core/constants/app_strings.dart';
import 'package:paycheck_calculator/core/constants/flags.dart';
import 'package:paycheck_calculator/data/models/country_model.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:paycheck_calculator/features/settings/settings_provider.dart';
import 'package:paycheck_calculator/features/settings/terms_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color _primary = Color(0xFF2563EB);

  bool _isRestoring = false;

  Future<void> _restorePurchases() async {
    if (_isRestoring) return;

    setState(() => _isRestoring = true);

    try {
      final customerInfo = await Purchases.restorePurchases();

      if (!mounted) return;

      final hasAccess = customerInfo.entitlements.active.containsKey('access');

      _showMessage(
        hasAccess
            ? 'Your subscription has been restored successfully.'
            : 'No active subscription was found for this account.',
      );
    } on PlatformException catch (e) {
      if (!mounted) return;

      _showMessage('Could not restore purchases. Please try again.');
      debugPrint('Restore purchases error: ${e.code} ${e.message}');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Something went wrong. Please try again.');
      debugPrint('Unexpected restore error: $e');
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  void _openTerms() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TermsScreen()));
  }

  void _showSupportDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'For help with Paycheck Calculator, contact the '
          'developer using the support contact provided '
          'on the app’s Google Play Store listing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calculator = context.watch<CalculatorProvider>();
    final settings = context.watch<SettingsProvider>();

    final country = countries.firstWhere(
      (c) => c.country == calculator.country,
      orElse: () => countries.first,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(country)),
            SliverToBoxAdapter(child: _buildAccountSection(country)),
            SliverToBoxAdapter(child: _buildPreferencesSection(settings)),
            SliverToBoxAdapter(child: _buildSupportSection()),
            SliverToBoxAdapter(child: _buildLegalSection()),
            SliverToBoxAdapter(child: _buildFooter()),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CountryOption country) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: _primary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(country.flag, style: const TextStyle(fontSize: 21)),
                const SizedBox(width: 8),
                Text(
                  country.currency,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openSubscriptionPlans() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()));
  }

  Widget _buildAccountSection(CountryOption country) {
    return _buildSection('ACCOUNT & SUBSCRIPTION', [
      _settingsTile(
        icon: Icons.workspace_premium_outlined,
        iconColor: _primary,
        iconBg: _primary.withValues(alpha: 0.10),
        title: 'Subscription plans',
        subtitle: 'View available plans and pricing',
        onTap: _openSubscriptionPlans,
      ),
      _settingsTile(
        icon: Icons.credit_card_outlined,
        iconColor: _primary,
        iconBg: _primary.withValues(alpha: 0.10),
        title: 'Manage subscription',
        subtitle: 'View or cancel through Google Play',
        onTap: () => openUrl(context, url: playSubscriptionsUrl),
      ),
      _settingsTile(
        icon: Icons.account_balance_wallet_outlined,
        iconColor: Colors.teal,
        iconBg: Colors.teal.withValues(alpha: 0.10),
        title: 'Currency',
        subtitle: 'Your selected calculation region',
        trailing: Text(
          country.currency,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
        showDivider: false,
      ),
    ]);
  }

  Widget _buildPreferencesSection(SettingsProvider settings) {
    return _buildSection('PREFERENCES', [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _iconBox(Icons.dark_mode_outlined, _primary),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark mode',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Adjust the app appearance',
                    style: TextStyle(fontSize: 12, color: AppColors.textGray),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: settings.isDark,
              activeTrackColor: _primary,
              onChanged: settings.toggleDarkMode,
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildSupportSection() {
    return _buildSection('SUPPORT', [
      _settingsTile(
        icon: Icons.help_outline_rounded,
        iconColor: Colors.teal,
        iconBg: Colors.teal.withValues(alpha: 0.10),
        title: 'Help & Support',
        subtitle: 'Get help with the app',
        onTap: _showSupportDialog,
      ),
      _settingsTile(
        icon: Icons.restore_rounded,
        iconColor: _primary,
        iconBg: _primary.withValues(alpha: 0.10),
        title: 'Restore purchases',
        subtitle: 'Recover an existing subscription',
        trailing: _isRestoring
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
        onTap: _isRestoring ? null : _restorePurchases,
        showDivider: false,
      ),
    ]);
  }

  Widget _buildLegalSection() {
    return _buildSection('LEGAL', [
      _settingsTile(
        icon: Icons.privacy_tip_outlined,
        iconColor: _primary,
        iconBg: _primary.withValues(alpha: 0.10),
        title: 'Privacy Policy',
        subtitle: 'How your information is handled',
        onTap: () => openUrl(context, url: privacyPolicyUrl),
      ),
      _settingsTile(
        icon: Icons.description_outlined,
        iconColor: Colors.deepOrange,
        iconBg: Colors.deepOrange.withValues(alpha: 0.10),
        title: 'Terms of Use',
        subtitle: 'Subscription and usage conditions',
        onTap: _openTerms,
        showDivider: false,
      ),
    ]);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 10),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  _iconBox(icon, iconColor, background: iconBg),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 11.5,
                              height: 1.4,
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 8), trailing],
                  if (onTap != null) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 21,
                      color: AppColors.textLight,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.6,
            indent: 58,
            endIndent: 16,
            color: AppColors.divider,
          ),
      ],
    );
  }

  Widget _iconBox(IconData icon, Color color, {Color? background}) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 28,
            color: _primary,
          ),
          const SizedBox(height: 8),
          const Text(
            'Paycheck Calculator',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            'Version $appVersion',
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
          const SizedBox(height: 8),
          const Text(
            'Estimates are for informational purposes only.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}

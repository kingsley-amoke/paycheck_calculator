import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/config/theme.dart';
import 'package:paycheck_calculator/core/widgets/splash.dart';
import 'package:paycheck_calculator/features/onboarding/screens/onboarding_screen.dart';
import 'package:paycheck_calculator/features/paywall/paywall_host.dart';
import 'package:paycheck_calculator/features/settings/settings_provider.dart';
import 'package:provider/provider.dart';

class PaycheckApp extends StatelessWidget {
  const PaycheckApp({super.key, required this.onboardingComplete});

  /// True when the user has completed onboarding in any previous session —
  /// the bootstrapper reads `LocalStorageService.onboardingCompleteKey`.
  final bool onboardingComplete;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paycheck',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: context.watch<SettingsProvider>().isDark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: onboardingComplete
          ? const PaywallHost(child: MainShell())
          : const OnboardingScreen(),
    );
  }
}

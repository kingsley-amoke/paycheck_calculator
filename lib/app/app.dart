import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/config/theme.dart';
import 'package:paycheck_calculator/features/onboarding/screens/hook.dart';
import 'package:paycheck_calculator/features/settings/settings_provider.dart';
import 'package:provider/provider.dart';

class PaycheckApp extends StatelessWidget {
  const PaycheckApp({super.key});

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
      home: const OnboardingScreen(),
    );
  }
}

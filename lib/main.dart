import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:paycheck_calculator/features/settings/settings_provider.dart';
import 'package:paycheck_calculator/features/subscription/provider/subscription_provider.dart';
import 'package:paycheck_calculator/features/subscription/services/revenuecat_service.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final revenueCat = RevenueCatService();

  await revenueCat.init("test_KPPDSiXGBWMyDxraAMjsUqnsZgg", null);

  final subscriptionProvider = SubscriptionProvider(revenueCat);

  await subscriptionProvider.refresh();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),

        ChangeNotifierProvider(create: (_) => SettingsProvider()),

        ChangeNotifierProvider.value(value: subscriptionProvider),
      ],

      child: const PaycheckApp(),
    ),
  );
}

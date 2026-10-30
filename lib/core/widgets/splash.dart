import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/services/local_storage_service.dart';
import 'package:paycheck_calculator/features/calculator/presentation/screens/annual_projection_screen.dart';
import 'package:paycheck_calculator/features/calculator/presentation/screens/compare_hub_screen.dart';

import '../../features/calculator/presentation/screens/home_screen.dart';
import '../../features/settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Single funnel: any entry into the app proper (skip, purchase, or
    // normal session) marks onboarding complete. Idempotent per session;
    // a failed write must never take the shell down.
    LocalStorageService.openStateBox()
        .then((box) {
          box.put(LocalStorageService.onboardingCompleteKey, true);
        })
        .catchError((_) {});
  }

  late final List<Widget> _screens = [
    const HomeScreen(),
    const CompareHubScreen(),
    const AnnualProjectionScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: colors.primary.withValues(alpha: 1),
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded),
            label: 'Calculate',
          ),
          NavigationDestination(
            icon: Icon(Icons.compare_arrows_outlined),
            selectedIcon: Icon(Icons.compare_arrows_rounded),
            label: 'Compare',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up_rounded),
            label: 'Projections',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

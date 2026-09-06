import 'package:flutter/material.dart';
import 'package:paycheck_calculator/features/calculator/presentation/screens/compare_screen.dart';
import '../../features/calculator/presentation/screens/home_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../constants/app_colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CompareTaxScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                0,
                Icons.calculate_rounded,
                Icons.calculate_sharp,
                'CALCULATE',
              ),
              _navItem(
                1,
                Icons.compare_arrows_outlined,
                Icons.compare_arrows,
                'COMPARE',
              ),
              _navItem(2, Icons.settings_outlined, Icons.settings, 'SETTINGS'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔥 ICON ANIMATION (UPGRADED)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack, // 🔥 spring feel
                );

                return ScaleTransition(
                  scale: curved,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: AnimatedScale(
                key: ValueKey(isActive),
                duration: const Duration(milliseconds: 250),
                scale: isActive ? 1.2 : 1.0, // 🔥 pop effect
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.primary : AppColors.textGray,
                  size: 22,
                ),
              ),
            ),

            const SizedBox(height: 4),

            // 🔥 TEXT ANIMATION
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isActive ? 1 : 0.7,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                offset: isActive ? const Offset(0, 0) : const Offset(0, 0.2),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.primary : AppColors.textGray,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

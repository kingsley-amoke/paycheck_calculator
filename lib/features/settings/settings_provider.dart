import 'package:flutter/cupertino.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  void toggleDarkMode(bool isDark) {
    _isDark = isDark;
    notifyListeners();
  }
}

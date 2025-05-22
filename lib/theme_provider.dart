import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _prefDynamicColorKey = 'dynamic_color_enabled';
  static const _prefThemeModeKey = 'theme_mode';

  bool _dynamicColorEnabled;
  ThemeMode _themeMode;

  ThemeProvider({bool dynamicColorEnabled = false, ThemeMode themeMode = ThemeMode.system})
      : _dynamicColorEnabled = dynamicColorEnabled,
        _themeMode = themeMode;

  // Existing getters and setters
  bool get dynamicColorEnabled => _dynamicColorEnabled;

  set dynamicColorEnabled(bool value) {
    if (_dynamicColorEnabled != value) {
      _dynamicColorEnabled = value;
      _saveDynamicColorPref(value);
      notifyListeners();
    }
  }

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _saveThemeModePref(mode);
      notifyListeners();
    }
  }

  // Add methods your UI code calls

  // setTheme to set themeMode
  void setTheme(ThemeMode mode) {
    themeMode = mode;
  }

  // useDynamicColor getter (alias for dynamicColorEnabled)
  bool get useDynamicColor => dynamicColorEnabled;

  // setUseDynamicColor method (alias for setter)
  void setUseDynamicColor(bool enabled) {
    dynamicColorEnabled = enabled;
  }

  /// Load saved preferences asynchronously
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _dynamicColorEnabled = prefs.getBool(_prefDynamicColorKey) ?? _dynamicColorEnabled;
    final themeModeIndex = prefs.getInt(_prefThemeModeKey);
    if (themeModeIndex != null && themeModeIndex >= 0 && themeModeIndex <= 2) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }
    notifyListeners();
  }

  Future<void> _saveDynamicColorPref(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefDynamicColorKey, value);
  }

  Future<void> _saveThemeModePref(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefThemeModeKey, mode.index);
  }
}
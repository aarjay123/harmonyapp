import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colour_schemes.dart'; // import predefined color schemes

class ThemeProvider extends ChangeNotifier {
  static const _prefDynamicColorKey = 'dynamic_color_enabled';
  static const _prefThemeModeKey = 'theme_mode';
  static const _prefSelectedSchemeKey = 'selected_scheme_key';

  bool _dynamicColorEnabled;
  ThemeMode _themeMode;
  String _selectedSchemeKey;

  ThemeProvider({
    bool dynamicColorEnabled = false,
    ThemeMode themeMode = ThemeMode.system,
    String selectedSchemeKey = 'Default Blue', // default: must match a key from predefinedThemes
  })  : _dynamicColorEnabled = dynamicColorEnabled,
        _themeMode = themeMode,
        _selectedSchemeKey = selectedSchemeKey;

  bool get dynamicColorEnabled => _dynamicColorEnabled;
  ThemeMode get themeMode => _themeMode;
  String get selectedSchemeKey => _selectedSchemeKey;

  // Alias for convenience
  bool get useDynamicColor => dynamicColorEnabled;
  void setUseDynamicColor(bool enabled) {
    dynamicColorEnabled = enabled;
  }

  set dynamicColorEnabled(bool value) {
    if (_dynamicColorEnabled != value) {
      _dynamicColorEnabled = value;
      _saveDynamicColorPref(value);
      notifyListeners();
    }
  }

  set themeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _saveThemeModePref(mode);
      notifyListeners();
    }
  }

  void setTheme(ThemeMode mode) {
    themeMode = mode;
  }

  void setPredefinedColorScheme(String key) {
    if (_selectedSchemeKey != key && predefinedThemes.containsKey(key)) {
      _selectedSchemeKey = key;
      _saveSelectedSchemeKey(key);
      notifyListeners();
    }
  }

  ColorScheme get currentColorScheme {
    if (_dynamicColorEnabled) {
      // Example fallback when dynamic color is enabled
      return ColorScheme.fromSeed(seedColor: Colors.teal);
    } else {
      return predefinedThemes[_selectedSchemeKey] ?? predefinedThemes.values.first;
    }
  }

  /// Load saved preferences asynchronously
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _dynamicColorEnabled = prefs.getBool(_prefDynamicColorKey) ?? _dynamicColorEnabled;

    final themeModeIndex = prefs.getInt(_prefThemeModeKey);
    if (themeModeIndex != null && themeModeIndex >= 0 && themeModeIndex <= 2) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }

    final savedSchemeKey = prefs.getString(_prefSelectedSchemeKey);
    if (savedSchemeKey != null && predefinedThemes.containsKey(savedSchemeKey)) {
      _selectedSchemeKey = savedSchemeKey;
    } else if (!predefinedThemes.containsKey(_selectedSchemeKey)) {
      // fallback to first key in map if current key invalid
      _selectedSchemeKey = predefinedThemes.keys.first;
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

  Future<void> _saveSelectedSchemeKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefSelectedSchemeKey, key);
  }
}
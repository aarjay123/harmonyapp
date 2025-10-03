import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Required for JSON encoding/decoding
import 'app_colour_schemes.dart'; // import predefined color schemes

class ThemeProvider extends ChangeNotifier {
  // Existing preference keys
  static const _prefDynamicColorKey = 'dynamic_color_enabled';
  static const _prefThemeModeKey = 'theme_mode';
  static const _prefSelectedSchemeKey = 'selected_scheme_key';
  static const _prefUseMaterial3Key = 'use_material3';
  static const _prefNavigationVisibilityKey = 'navigation_visibility';
  // NEW: Preference key for the ads enabled setting.
  static const _prefAdsEnabledKey = 'ads_enabled';

  // Existing properties
  bool _dynamicColorEnabled;
  ThemeMode _themeMode;
  String _selectedSchemeKey;
  bool _useMaterial3;
  // NEW: Property to hold the state of ads. Defaults to true.
  bool _adsEnabled = true;

  Map<String, bool> _visibleDestinations = {
    'food': true,
    'rewards': true,
    'hotel': true,
    'room_key': true,
  };

  ThemeProvider({
    bool dynamicColorEnabled = false,
    ThemeMode themeMode = ThemeMode.system,
    String selectedSchemeKey = 'Default Blue',
    bool useMaterial3 = true,
  })  : _dynamicColorEnabled = dynamicColorEnabled,
        _themeMode = themeMode,
        _selectedSchemeKey = selectedSchemeKey,
        _useMaterial3 = useMaterial3;

  // Existing getters
  bool get dynamicColorEnabled => _dynamicColorEnabled;
  ThemeMode get themeMode => _themeMode;
  String get selectedSchemeKey => _selectedSchemeKey;
  bool get useMaterial3 => _useMaterial3;
  Map<String, bool> get visibleDestinations => _visibleDestinations;

  // NEW: Getter for the ads enabled state.
  bool get adsEnabled => _adsEnabled;

  // NEW: Setter for the ads enabled state, with saving and notification.
  set adsEnabled(bool value) {
    if (_adsEnabled != value) {
      _adsEnabled = value;
      _saveAdsEnabledPref(value);
      notifyListeners();
    }
  }

  // Existing setters and methods
  bool get useDynamicColor => dynamicColorEnabled;
  setUseDynamicColor(bool enabled) => dynamicColorEnabled = enabled;

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

  void setTheme(ThemeMode mode) => themeMode = mode;

  void setPredefinedColorScheme(String key) {
    if (_selectedSchemeKey != key && predefinedThemes.containsKey(key)) {
      _selectedSchemeKey = key;
      _saveSelectedSchemeKey(key);
      notifyListeners();
    }
  }

  set useMaterial3(bool value) {
    if (_useMaterial3 != value) {
      _useMaterial3 = value;
      _saveUseMaterial3Pref(value);
      notifyListeners();
    }
  }

  ColorScheme get currentColorScheme {
    if (_dynamicColorEnabled) {
      return ColorScheme.fromSeed(seedColor: Colors.teal);
    } else {
      return predefinedThemes[_selectedSchemeKey] ?? predefinedThemes.values.first;
    }
  }

  Future<void> updateDestinationVisibility(String id, bool isVisible) async {
    if (_visibleDestinations.containsKey(id)) {
      _visibleDestinations[id] = isVisible;
      await _saveNavigationPreferences();
      notifyListeners();
    }
  }

  // --- Preference Loading and Saving ---

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _dynamicColorEnabled = prefs.getBool(_prefDynamicColorKey) ?? _dynamicColorEnabled;

    final themeModeIndex = prefs.getInt(_prefThemeModeKey);
    if (themeModeIndex != null && themeModeIndex >= 0 && themeModeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }

    final savedSchemeKey = prefs.getString(_prefSelectedSchemeKey);
    if (savedSchemeKey != null && predefinedThemes.containsKey(savedSchemeKey)) {
      _selectedSchemeKey = savedSchemeKey;
    } else if (!predefinedThemes.containsKey(_selectedSchemeKey)) {
      _selectedSchemeKey = predefinedThemes.keys.first;
    }

    _useMaterial3 = prefs.getBool(_prefUseMaterial3Key) ?? true;

    // NEW: Load the ads enabled preference, defaulting to true.
    _adsEnabled = prefs.getBool(_prefAdsEnabledKey) ?? true;

    await _loadNavigationPreferences(prefs);

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

  Future<void> _saveUseMaterial3Pref(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefUseMaterial3Key, value);
  }

  // NEW: Method to save the ads enabled preference.
  Future<void> _saveAdsEnabledPref(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefAdsEnabledKey, value);
  }

  Future<void> _saveNavigationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String navSettingsString = json.encode(_visibleDestinations);
    await prefs.setString(_prefNavigationVisibilityKey, navSettingsString);
  }

  Future<void> _loadNavigationPreferences(SharedPreferences prefs) async {
    String? navSettingsString = prefs.getString(_prefNavigationVisibilityKey);
    if (navSettingsString != null) {
      try {
        Map<String, dynamic> loadedSettings = json.decode(navSettingsString);
        Map<String, bool> updatedSettings = {};
        for (var key in _visibleDestinations.keys) {
          updatedSettings[key] = loadedSettings[key] as bool? ?? true;
        }
        _visibleDestinations = updatedSettings;
      } catch (e) {
        debugPrint("Could not parse navigation settings: $e");
      }
    }
  }
}
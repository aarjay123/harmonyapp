// lib/main.dart

// Import Flutter core libraries
import 'package:flutter/material.dart';

// Import third-party packages
import 'package:provider/provider.dart';

// Import your own app files
import 'theme_provider.dart'; // Assumed path
import 'device_info_helper.dart'; // Assumed path
import 'app.dart'; // The new root app widget

// The main entry point of the Flutter app
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter engine is initialized before running app
  runApp(const AppLoader()); // Runs the root widget AppLoader
}

// Stateful widget to handle async initialization before showing main app.
class AppLoader extends StatefulWidget {
  const AppLoader({Key? key}) : super(key: key);

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  ThemeProvider? _themeProvider; // Holds the theme provider instance once loaded
  bool _error = false; // Flag to indicate if initialization failed
  bool _dynamicColorSupported = false; // Flag for whether dynamic color is supported on device

  @override
  void initState() {
    super.initState();
    _initTheme(); // Start theme initialization asynchronously on widget load
  }

  // Async method to initialize theme provider and detect dynamic color support
  Future<void> _initTheme() async {
    try {
      // Check device capability for dynamic color (Android 12+)
      final supported = await DeviceInfoHelper.supportsDynamicColor();
      _dynamicColorSupported = supported;

      // Create theme provider with dynamic color enabled flag
      final themeProvider = ThemeProvider(dynamicColorEnabled: supported);
      await themeProvider.loadPreferences(); // Load saved user theme preferences

      // If device doesn't support dynamic color, forcibly disable it in provider
      if (!supported) {
        themeProvider.dynamicColorEnabled = false;
      }

      // Update state with loaded provider instance, triggers UI rebuild
      if (mounted) {
        setState(() {
          _themeProvider = themeProvider;
        });
      }
    } catch (e, st) {
      // On error, log and set error flag to show error UI
      debugPrint('Failed to init theme: $e\n$st');
      if (mounted) {
        setState(() {
          _error = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If error occurred or theme provider is still null (loading), show error/loading UI
    if (_error || _themeProvider == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Failed to load preferences')),
        ),
      );
    }

    // Provide the loaded ThemeProvider to the widget subtree via Provider package
    // We're using the 'Harmony' widget as requested in the previous step.
    return ChangeNotifierProvider.value(
      value: _themeProvider!,
      child: Harmony(dynamicColourSupported: _dynamicColorSupported),
    );
  }
}
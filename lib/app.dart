// lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'theme_provider.dart'; // Assumed path
import 'colour_scheme.dart'; // Assumed path
import 'global_slide_transition_builder.dart'; // Assumed path
import 'widgets/responsive_scaffold.dart'; // Import the refactored scaffold

// Main app widget, builds MaterialApp with theming based on dynamic color support and user preference
class Harmony extends StatelessWidget {
  final bool dynamicColourSupported; // Passed from AppLoader, device capability flag

  const Harmony({Key? key, required this.dynamicColourSupported}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      // Builder provides dynamic light and dark color schemes if available
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final themeProvider = Provider.of<ThemeProvider>(context);

        // Determine if dynamic color should be used based on device and user settings
        final useDynamic =
            themeProvider.dynamicColorEnabled && dynamicColourSupported;

        // Common CardThemeData definition based on Material 3 toggle
        final CardThemeData commonCardTheme = CardThemeData(
          // Sharper corners for Material 2, softer for Material 3
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(themeProvider.useMaterial3 ? 12.0 : 8.0),
          ),
          // More pronounced shadow for Material 2, subtle for Material 3
          elevation: themeProvider.useMaterial3 ? 1.0 : 4.0,
        );

        if (useDynamic) {
          // If dynamic colors enabled and supported, build MaterialApp using them
          return _buildMaterialApp(
            themeProvider: themeProvider,
            lightScheme: lightDynamic ?? lightColorScheme,
            darkScheme: darkDynamic ?? darkColorScheme,
            commonCardTheme: commonCardTheme,
          );
        }

        // Otherwise, build app with user's selected color scheme (no dynamic color)
        final ColorScheme lightScheme = themeProvider.currentColorScheme;
        final ColorScheme darkScheme = ColorScheme.fromSeed(
          seedColor: lightScheme.primary,
          brightness: Brightness.dark,
        );

        return _buildMaterialApp(
          themeProvider: themeProvider,
          lightScheme: lightScheme,
          darkScheme: darkScheme,
          commonCardTheme: commonCardTheme,
        );
      },
    );
  }

  // Helper method to build the MaterialApp to reduce code duplication
  MaterialApp _buildMaterialApp({
    required ThemeProvider themeProvider,
    required ColorScheme lightScheme,
    required ColorScheme darkScheme,
    required CardThemeData commonCardTheme,
  }) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Harmony',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: themeProvider.useMaterial3,
        colorScheme: lightScheme,
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Outfit'),
        cardTheme: commonCardTheme,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            for (final platform in TargetPlatform.values)
              platform: GlobalSlidePageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: themeProvider.useMaterial3,
        colorScheme: darkScheme,
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Outfit'),
        cardTheme: commonCardTheme,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            for (final platform in TargetPlatform.values)
              platform: GlobalSlidePageTransitionsBuilder(),
          },
        ),
      ),
      home: ResponsiveScaffold(dynamicColorSupported: dynamicColourSupported),
    );
  }
}
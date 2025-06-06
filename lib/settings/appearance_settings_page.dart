import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

// Local Imports
import '../theme_provider.dart';
import '../app_colour_schemes.dart';
import '../device_info_helper.dart';
import '../settings_ui_components.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  static const double _dropdownWidth = 200;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<bool>(
      future: DeviceInfoHelper.supportsDynamicColor(),
      builder: (context, snapshot) {
        final bool supportsDynamicColor = snapshot.data ?? false;
        final bool dynamicColorEnabled = themeProvider.useDynamicColor;

        return SettingsPageTemplate(
          title: "Appearance",
          children: [
            // --- Appearance Group ---
            const SettingsGroupTitle(title: "Theme & Colours"),
            SettingsListItem(
              icon: Icons.brightness_6_rounded,
              label: "Theme",
              trailing: _buildThemeDropdown(context, themeProvider, colorScheme),
              isFirstItem: true,
            ),
            SettingsListItem(
              icon: Icons.format_color_fill_rounded,
              label: "Use Dynamic Colour",
              subtitle: "Uses colours from your wallpaper",
              trailing: Switch(
                value: dynamicColorEnabled,
                onChanged: supportsDynamicColor
                    ? (value) => themeProvider.setUseDynamicColor(value)
                    : null,
                activeColor: supportsDynamicColor
                    ? null
                    : colorScheme.onSurface.withOpacity(0.38),
              ),
              // Determine if this is the last item based on whether the next item is visible
              isLastItem: dynamicColorEnabled,
            ),
            // Conditionally show the color scheme picker
            if (!dynamicColorEnabled)
              SettingsListItem(
                icon: Icons.color_lens_rounded,
                label: "App Colours",
                trailing: _buildSchemeDropdown(context, themeProvider, colorScheme),
                isLastItem: true, // This is now definitively the last item
              ),
          ],
        );
      },
    );
  }

  // Dropdown for selecting the app theme (Light, Dark, System)
  Widget _buildThemeDropdown(BuildContext context, ThemeProvider provider, ColorScheme colorScheme) {
    return SizedBox(
      width: _dropdownWidth,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<ThemeMode>(
          isExpanded: true,
          value: provider.themeMode,
          onChanged: (ThemeMode? mode) {
            if (mode != null) provider.setTheme(mode);
          },
          items: const [
            DropdownMenuItem(value: ThemeMode.system, child: Text("System")),
            DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
            DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
          ],
          buttonStyleData: _dropdownButtonStyle(colorScheme),
          dropdownStyleData: _dropdownStyle(colorScheme, 160),
          iconStyleData: _dropdownIconStyle(colorScheme),
        ),
      ),
    );
  }

  // Dropdown for selecting a predefined color scheme
  Widget _buildSchemeDropdown(BuildContext context, ThemeProvider provider, ColorScheme colorScheme) {
    return SizedBox(
      width: _dropdownWidth,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          value: provider.selectedSchemeKey,
          onChanged: (String? key) {
            if (key != null) provider.setPredefinedColorScheme(key);
          },
          items: predefinedThemes.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.key),
            );
          }).toList(),
          buttonStyleData: _dropdownButtonStyle(colorScheme),
          dropdownStyleData: _dropdownStyle(colorScheme, 200),
          iconStyleData: _dropdownIconStyle(colorScheme),
        ),
      ),
    );
  }

  // Helper methods for consistent dropdown styling
  ButtonStyleData _dropdownButtonStyle(ColorScheme colorScheme) {
    return ButtonStyleData(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
        color: colorScheme.surface,
      ),
      elevation: 0,
    );
  }

  DropdownStyleData _dropdownStyle(ColorScheme colorScheme, double maxHeight) {
    return DropdownStyleData(
      maxHeight: maxHeight,
      width: _dropdownWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      elevation: 8,
      scrollbarTheme: ScrollbarThemeData(
        radius: const Radius.circular(8),
        thickness: MaterialStateProperty.all(6),
        thumbVisibility: MaterialStateProperty.all(true),
      ),
    );
  }

  IconStyleData _dropdownIconStyle(ColorScheme colorScheme) {
    return IconStyleData(
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.onSurfaceVariant),
      iconSize: 24,
    );
  }
}
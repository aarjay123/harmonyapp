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

    // The 'dashboard' item has been removed as it is no longer optional.
    const navItemNames = {
      'food': 'Food Page',
      'rewards': 'Rewards Page',
      'hotel': 'Hotel Page',
      'room_key': 'Room Key Page',
    };

    return FutureBuilder<bool>(
      future: DeviceInfoHelper.supportsDynamicColor(),
      builder: (context, snapshot) {
        final bool supportsDynamicColor = snapshot.data ?? false;
        final bool dynamicColorEnabled = themeProvider.useDynamicColor;
        final bool useMaterial3 = themeProvider.useMaterial3;

        return SettingsPageTemplate(
          title: "Appearance",
          children: [
            // --- Theme & Colours Group ---
            const SettingsGroupTitle(title: "Theme & Colours"),
            SettingsListItem(
              icon: Icons.brightness_6_rounded,
              label: "Theme",
              trailing: _buildThemeDropdown(context, themeProvider, colorScheme),
              isFirstItem: true,
              isLastItem: false,
            ),
            SettingsListItem(
              icon: Icons.format_color_fill_rounded,
              label: "Use Dynamic Colour",
              subtitle: "Uses colours from your wallpaper (Android 12+)",
              trailing: Switch(
                value: dynamicColorEnabled,
                onChanged: supportsDynamicColor
                    ? (value) => themeProvider.setUseDynamicColor(value)
                    : null,
              ),
              isLastItem: false,
            ),
            SettingsListItem(
              icon: Icons.design_services_rounded,
              label: "Use Material 3 Design",
              subtitle: "Modern UI elements and features",
              trailing: Switch(
                value: useMaterial3,
                onChanged: (value) => themeProvider.useMaterial3 = value,
              ),
              isLastItem: dynamicColorEnabled,
            ),
            if (!dynamicColorEnabled)
              SettingsListItem(
                icon: Icons.color_lens_rounded,
                label: "App Colours",
                trailing: _buildSchemeDropdown(context, themeProvider, colorScheme),
                isLastItem: true,
              ),

            // --- UPDATED: Section Renamed and Restyled ---
            const SettingsGroupTitle(title: "Add or Remove Features"),
            // UPDATED: Now uses a list of SettingsListItem for a cleaner look.
            ...navItemNames.entries.map((entry) {
              final String id = entry.key;
              final String name = entry.value;
              final bool isVisible = themeProvider.visibleDestinations[id] ?? true;
              // Determine if the item is first or last in the list for proper corner rounding.
              final bool isFirst = id == navItemNames.keys.first;
              final bool isLast = id == navItemNames.keys.last;

              return SettingsListItem(
                icon: Icons.visibility_rounded, // Using a generic icon for consistency
                label: name,
                trailing: Switch(
                  value: isVisible,
                  onChanged: (bool value) {
                    themeProvider.updateDestinationVisibility(id, value);
                  },
                ),
                isFirstItem: isFirst,
                isLastItem: isLast,
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // --- Helper methods for dropdowns (no changes needed here) ---

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

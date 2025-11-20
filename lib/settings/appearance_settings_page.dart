import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

// Local Imports
import '../theme_provider.dart';
import '../app_colour_schemes.dart';
import '../device_info_helper.dart';
// We don't need settings_ui_components.dart anymore as we are building custom UI
// import '../settings_ui_components.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  static const double _dropdownWidth = 160;

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

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: CustomScrollView(
            slivers: [
              // --- Modern Header ---
              SliverAppBar.large(
                title: Text('Appearance', style: TextStyle(color: colorScheme.onSurface)),
                backgroundColor: colorScheme.surface,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.purple.withOpacity(0.2), // Matching the purple theme from SettingsPage
                          colorScheme.surface,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Icon(
                          Icons.palette_rounded,
                          size: 80,
                          color: Colors.purple.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // --- Content ---
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // --- Theme & Colours Section ---
                    _buildSectionHeader(context, "Theme & Colours"),
                    Card(
                      elevation: 0,
                      color: colorScheme.primaryContainer.withOpacity(0.5),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      child: Column(
                        children: [
                          // Theme Dropdown
                          ListTile(
                            leading: Icon(Icons.brightness_6_outlined, color: colorScheme.primary),
                            title: const Text("Theme"),
                            trailing: _buildThemeDropdown(context, themeProvider, colorScheme),
                          ),
                          Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant),

                          // Dynamic Color Switch
                          SwitchListTile(
                            secondary: Icon(Icons.format_color_fill_outlined, color: colorScheme.primary),
                            title: const Text("Use Dynamic Colour"),
                            subtitle: const Text("Match wallpaper (Android 12+)"),
                            value: dynamicColorEnabled,
                            onChanged: supportsDynamicColor
                                ? (value) => themeProvider.setUseDynamicColor(value)
                                : null,
                          ),

                          // App Colours Dropdown (only if dynamic color is off)
                          if (!dynamicColorEnabled) ...[
                            Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant),
                            ListTile(
                              leading: Icon(Icons.color_lens_outlined, color: colorScheme.primary),
                              title: const Text("App Colours"),
                              trailing: _buildSchemeDropdown(context, themeProvider, colorScheme),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- Features Section ---
                    _buildSectionHeader(context, "Customise Features"),
                    Card(
                      elevation: 0,
                      color: colorScheme.primaryContainer.withOpacity(0.5),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      child: Column(
                        children: [
                          ...navItemNames.entries.map((entry) {
                            final String id = entry.key;
                            final String name = entry.value;
                            final bool isVisible = themeProvider.visibleDestinations[id] ?? true;
                            final bool isLast = id == navItemNames.keys.last;

                            return Column(
                              children: [
                                SwitchListTile(
                                  secondary: Icon(Icons.visibility_outlined, color: colorScheme.primary),
                                  title: Text(name),
                                  value: isVisible,
                                  onChanged: (bool value) {
                                    themeProvider.updateDestinationVisibility(id, value);
                                  },
                                ),
                                if (!isLast)
                                  Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- Helper methods for dropdowns ---

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
              child: Text(entry.key, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          buttonStyleData: _dropdownButtonStyle(colorScheme),
          dropdownStyleData: _dropdownStyle(colorScheme, 300),
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
        color: colorScheme.secondaryContainer, // Slightly darker to stand out on the card
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
        color: colorScheme.secondaryContainer,
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
        thickness: WidgetStateProperty.all(6),
        thumbVisibility: WidgetStateProperty.all(true),
      ),
    );
  }

  IconStyleData _dropdownIconStyle(ColorScheme colorScheme) {
    return IconStyleData(
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.onSurfaceVariant),
      iconSize: 20,
    );
  }
}
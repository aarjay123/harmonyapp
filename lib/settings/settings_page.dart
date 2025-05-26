import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../theme_provider.dart';
import '../app_colour_schemes.dart';

import 'privacy_policy_page.dart';
import 'websites_page.dart';
import 'updates_page.dart';
import 'apps_services_page.dart';
import 'socials_page.dart';
import 'web_settings_page.dart';
import 'about_hioswebcore.dart';

import '../device_info_helper.dart';
import '../settings_ui_components.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${info.version}+${info.buildNumber}';
    });
  }

  static const double dropdownWidth = 200; // Common dropdown width

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return FutureBuilder<bool>(
      future: DeviceInfoHelper.supportsDynamicColor(),
      builder: (context, snapshot) {
        final bool supportsDynamicColor = snapshot.data ?? false;
        final bool dynamicColorEnabled = themeProvider.useDynamicColor;

        final groups = [
          _SettingsGroup(
            title: "Appearance",
            items: [
              _SettingsItem(
                icon: Icons.brightness_6_rounded,
                label: "Theme",
                trailing: _themeDropdown(themeProvider, colorScheme),
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.format_color_fill_rounded,
                label: "Use Dynamic Colour",
                trailing: Switch(
                  value: dynamicColorEnabled,
                  onChanged: supportsDynamicColor
                      ? (value) => themeProvider.setUseDynamicColor(value)
                      : null,
                  activeColor: supportsDynamicColor
                      ? null
                      : colorScheme.onSurface.withOpacity(0.38),
                ),
                onTap: () {},
              ),
              if (!dynamicColorEnabled)
                _SettingsItem(
                  icon: Icons.color_lens_rounded,
                  label: "Color Scheme",
                  trailing: _schemeDropdown(themeProvider, colorScheme),
                  onTap: () {},
                ),
            ],
          ),
          _SettingsGroup(
            title: "General",
            items: [
              _SettingsItem(
                icon: Icons.system_update_rounded,
                label: "Updates",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpdatesPage()),
                ),
              ),
              _SettingsItem(
                icon: Icons.apps_rounded,
                label: "Apps & Services",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppsServicesPage()),
                ),
              ),
              _SettingsItem(
                icon: Icons.language_rounded,
                label: "Websites",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WebsitesPage()),
                ),
              ),
              _SettingsItem(
                icon: Icons.people_rounded,
                label: "Socials",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SocialsPage()),
                ),
              ),
            ],
          ),
          _SettingsGroup(
            title: "About",
            items: [
              _SettingsItem(
                icon: Icons.perm_device_info_rounded,
                label: "About App",
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Harmony by The Highland Cafe',
                  applicationVersion: '$_version',
                  applicationLegalese:
                  'Copyright © The Highland Cafe™ Ltd. 2025. All rights Reserved.',
                ),
              ),
              _SettingsItem(
                icon: Icons.privacy_tip_rounded,
                label: "Privacy Policy",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                ),
              ),
            ],
          ),
        ];

        return Scaffold(
          appBar: AppBar(title: const Text("Settings")),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, groupIndex) {
                final group = groups[groupIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use the shared SettingsGroupTitle widget
                    SettingsGroupTitle(title: group.title),
                    // Items in the group
                    Column(
                      children: List.generate(group.items.length, (index) {
                        final itemData = group.items[index];
                        final isFirst = index == 0;
                        final isLast = index == group.items.length - 1;

                        // Use the shared SettingsListItem widget
                        return SettingsListItem(
                          icon: itemData.icon,
                          label: itemData.label,
                          // subtitle: itemData.subtitle, // Uncomment if your _SettingsItem has subtitles
                          trailing: itemData.trailing,
                          onTap: itemData.onTap,
                          isFirstItem: isFirst,
                          isLastItem: isLast,
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _themeDropdown(ThemeProvider provider, ColorScheme colorScheme) {
    return SizedBox(
      width: dropdownWidth,
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
          buttonStyleData: ButtonStyleData(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline),
              color: colorScheme.primaryContainer,
            ),
            elevation: 0,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 160,
            width: dropdownWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: colorScheme.surface,
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
          ),
          iconStyleData: IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onPrimaryContainer),
            iconSize: 24,
          ),
        ),
      ),
    );
  }

  Widget _schemeDropdown(ThemeProvider provider, ColorScheme colorScheme) {
    return SizedBox(
      width: dropdownWidth,
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
          buttonStyleData: ButtonStyleData(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline),
              color: colorScheme.primaryContainer,
            ),
            elevation: 0,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            width: dropdownWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(8),
              thickness: MaterialStateProperty.all(6),
              thumbVisibility: MaterialStateProperty.all(true),
            ),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onPrimaryContainer),
            iconSize: 24,
          ),
        ),
      ),
    );
  }
}

class _SettingsGroup {
  final String title;
  final List<_SettingsItem> items;

  _SettingsGroup({required this.title, required this.items});
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  _SettingsItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });
}
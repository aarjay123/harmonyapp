import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Local Imports
import '../settings_ui_components.dart';
import 'appearance_settings_page.dart';

// Placeholder imports for navigation
import 'privacy_policy_page.dart';
import 'websites_page.dart';
import 'updates_page.dart';
import 'apps_services_page.dart';
import 'socials_page.dart';


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

  // Fetches the app version to display in the about dialog.
  Future<void> _loadVersionInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${info.version}+${info.buildNumber}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageTemplate(
      title: "Settings",
      children: [
        // --- General Group ---
        const SettingsGroupTitle(title: "General"),
        SettingsListItem(
          icon: Icons.palette_rounded,
          label: "Appearance",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppearanceSettingsPage()),
          ),
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.system_update_rounded,
          label: "Updates",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdatesPage()),
          ),
        ),
        SettingsListItem(
          icon: Icons.apps_rounded,
          label: "Apps & Services",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppsServicesPage()),
          ),
        ),
        SettingsListItem(
          icon: Icons.language_rounded,
          label: "Websites",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WebsitesPage()),
          ),
        ),
        SettingsListItem(
          icon: Icons.people_rounded,
          label: "Socials",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SocialsPage()),
          ),
          isLastItem: true,
        ),

        // --- About Group ---
        const SettingsGroupTitle(title: "About"),
        SettingsListItem(
          icon: Icons.perm_device_info_rounded,
          label: "About App",
          onTap: () => showAboutDialog(
            context: context,
            applicationName: 'Harmony by The Highland Cafe',
            applicationVersion: _version,
            applicationLegalese:
            'Copyright © The Highland Cafe™ Ltd. 2025. All rights Reserved.',
          ),
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.privacy_tip_rounded,
          label: "Privacy Policy",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
          ),
          isLastItem: true,
        ),
      ],
    );
  }
}
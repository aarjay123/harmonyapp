import 'package:flutter/material.dart';

// Local Imports
import '../settings_ui_components.dart';
import 'appearance_settings_page.dart';

// Placeholder imports for navigation
import 'privacy_policy_page.dart';
import 'websites_page.dart';
import 'updates_page.dart';
// NEW: Import the new about page
import 'about_page.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageTemplate(
      title: "Settings",
      children: [
        // --- General Group ---
        const SettingsGroupTitle(title: "General"),
        SettingsListItem(
          icon: Icons.palette_outlined,
          label: "Appearance",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppearanceSettingsPage()),
          ),
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.system_update,
          label: "Updates",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdatesPage()),
          ),
        ),
        SettingsListItem(
          icon: Icons.language_outlined,
          label: "Websites",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WebsitesPage()),
          ),
          // UPDATED: isLastItem is now true
          isLastItem: true,
        ),

        // --- About Group ---
        const SettingsGroupTitle(title: "About"),
        SettingsListItem(
          icon: Icons.info_outline,
          label: "About App",
          // UPDATED: onTap now navigates to the new AboutAppPage.
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutAppPage())),
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.privacy_tip_outlined,
          label: "Privacy Policy",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
          ),
          isLastItem: true,
        ),
      ],
    );
  }
}
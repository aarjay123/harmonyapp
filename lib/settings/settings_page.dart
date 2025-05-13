import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'privacy_policy_page.dart';
import 'websites_page.dart';
import 'updates_page.dart';
import 'apps_services_page.dart';
import 'socials_page.dart';
import 'web_settings_page.dart';
import 'about_hioswebcore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          // Appearance Settings (opens WebSettingsPage)
          ListTile(
            leading: const Icon(Icons.palette_rounded),
            title: const Text("Appearance Settings"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WebSettingsPage()),
              );
            },
          ),

          // Theme Mode
          ListTile(
            leading: const Icon(Icons.brightness_6_rounded),
            title: const Text("Theme"),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              onChanged: (ThemeMode? mode) {
                if (mode != null) {
                  themeProvider.setTheme(mode);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text("System"),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text("Light"),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text("Dark"),
                ),
              ],
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text("Updates"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const UpdatesPage(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.apps),
            title: const Text("Apps & Services"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const AppsServicesPage(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Websites"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const WebsitesPage(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Socials"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const SocialsPage(),
              ));
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_rounded),
            title: const Text("About HiOSCore"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const AboutHioswebcore(),
              ));
            },
          ),

          ListTile(
            leading: const Icon(Icons.perm_device_info_rounded),
            title: const Text("About App"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Harmony by The Highland Cafe',
                applicationVersion: '3.0',
                applicationLegalese: 'Copyright © The Highland Cafe™ Ltd. 2025. All rights Reserved.',
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Privacy Policy"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const PrivacyPolicyPage(),
              ));
            },
          ),
        ],
      ),
    );
  }
}

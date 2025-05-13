import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme_provider.dart';
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
  bool showWebPage = false;

  final String webSettingsUrl = "https://thehighlandcafe.github.io/hioswebcore/activities/settingsActivity/settings_activities/appearance_activity";
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..loadRequest(Uri.parse(webSettingsUrl));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: showWebPage
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            setState(() {
              showWebPage = false;
            });
          },
        )
            : null,
      ),
      body: showWebPage
          ? WebViewWidget(controller: _webViewController)
          : ListView(
        children: [
          // Theme dropdown
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

          // Appearance (WebView)
          ListTile(
            leading: const Icon(Icons.palette_rounded),
            title: const Text("Appearance Settings"),
            onTap: () {
              setState(() {
                showWebPage = true;
              });
            },
          ),

          // Subpages
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
            leading: const Icon(Icons.people),
            title: const Text("Socials"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const SocialsPage(),
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
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Privacy Policy"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const PrivacyPolicyPage(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Harmony by The Highland Cafe',
                applicationVersion: '3.0',
                applicationLegalese: 'Copyright © The Highland Cafe Ltd. 2025. All Rights Reserved.',
              );
            },
          ),
        ],
      ),
    );
  }
}

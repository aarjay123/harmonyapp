import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Local Imports
import '../settings_ui_components.dart';
import '../theme_provider.dart';
import 'appearance_settings_page.dart';
import 'privacy_policy_page.dart';
import 'websites_page.dart';
import 'updates_page.dart';
import 'about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Controller for the text field in the dialog.
  final TextEditingController _codeController = TextEditingController();

  // The secret code to disable ads.
  static const String _secretCode = "HIOSMOBILE2021";

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // Helper to launch a URL.
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  // Shows the dialog for entering the ad-removal code.
  void _showRemoveAdsDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Remove Ads"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // UPDATED: The text is now clearer about how to get the code.
              const Text("Tap the button to visit our Facebook page. The secret code will then appear here in a message."),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.facebook),
                label: const Text("Go to Facebook Page"),
                onPressed: () {
                  _launchUrl("https://www.facebook.com/profile.php?id=100095224335357");
                  // NEW: Show a SnackBar (toast) with the code after the button is tapped.
                  // We use the main `context` to ensure the SnackBar can find the Scaffold.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Hint: The secret code is $_secretCode"),
                      duration: Duration(seconds: 8), // Keep it on screen longer
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Secret Code",
                  hintText: "Enter code here",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (_codeController.text.trim() == _secretCode) {
                  // If the code is correct, update the provider and close the dialog.
                  themeProvider.adsEnabled = false;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Success! Ads have been disabled.")),
                  );
                } else {
                  // If incorrect, show an error and clear the field.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Incorrect code. Please try again."), backgroundColor: Colors.red),
                  );
                }
                _codeController.clear();
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // We need to watch the provider to rebuild when adsEnabled changes.
    final themeProvider = context.watch<ThemeProvider>();

    return SettingsPageTemplate(
      title: "Settings",
      children: [
        // --- General Group ---
        const SettingsGroupTitle(title: "General"),
        SettingsListItem(
          icon: Icons.palette_outlined,
          label: "Appearance",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppearanceSettingsPage())),
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.system_update,
          label: "Updates",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdatesPage())),
        ),
        SettingsListItem(
          icon: Icons.language_outlined,
          label: "Websites",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WebsitesPage())),
          isLastItem: true,
        ),

        // --- NEW: Support Group ---
        const SettingsGroupTitle(title: "Support Us"),
        // Conditionally show either the "Remove Ads" button or the "Ads Enabled" toggle.
        if (themeProvider.adsEnabled)
          SettingsListItem(
            icon: Icons.favorite_border_rounded,
            label: "Remove Ads",
            subtitle: "Follow us to get a code and enjoy an ad-free experience.",
            onTap: () => _showRemoveAdsDialog(context),
            isFirstItem: true,
            isLastItem: true,
          )
        else
          SettingsListItem(
            icon: Icons.favorite_rounded,
            label: "Ads Enabled",
            subtitle: "Thank you for your support!",
            trailing: Switch(
              value: themeProvider.adsEnabled,
              onChanged: (value) {
                themeProvider.adsEnabled = value;
              },
            ),
            isFirstItem: true,
            isLastItem: true,
          ),

        // --- About Group ---
        const SettingsGroupTitle(title: "About"),
        SettingsListItem(
          icon: Icons.info_outline,
          label: "About App",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutAppPage())),
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.privacy_tip_outlined,
          label: "Privacy Policy",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
          isLastItem: true,
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../settings_ui_components.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
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

  final String _latestUpdateUrl = 'https://github.com/aarjay123/harmonyapp/releases/latest';
  final String _autoUpdateUrl = 'https://hienterprises.github.io/harmony/autoupdate';
  final String _discordUrl = 'https://discord.gg/EDykxqwy';

  Future<void> _launchExternalUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch the website.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SettingsPageTemplate(
      title: "Updates",
      children: [
        const SettingsGroupTitle(title: "Update Harmony"),
        SettingsListItem(
          icon: Icons.download_rounded,
          label: "Manually Update Harmony",
          subtitle:
          "Download the latest app installer file.\n1. Tap here, then tap the installer matching your OS.\n2. Install the update how you usually would.",
          onTap: () => _launchExternalUrl(context, _latestUpdateUrl),
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.info_rounded,
          label: "This version: $_version",
          subtitle: null,
          onTap: () {}, // no action, but needed for InkWell
        ),
        SettingsListItem(
          icon: Icons.update_rounded,
          label: "Auto-Update Harmony on Android",
          subtitle: "Learn how to update Harmony on Android automatically on our website.",
          onTap: () => _launchExternalUrl(context, _autoUpdateUrl),
          isLastItem: true,
        ),

        const SettingsGroupTitle(title: "Update notifications and more"),
        SettingsListItem(
          icon: Icons.notifications_active_rounded,
          label: "Update Notifications",
          subtitle: "Join our Discord server to get notified every time we update Harmony.",
          onTap: () => _launchExternalUrl(context, _discordUrl), // no action, but needed for InkWell
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.new_releases_rounded,
          label: "What's New?",
          subtitle: null,
          onTap: () => _launchExternalUrl(context, _latestUpdateUrl),
          isLastItem: true,
        ),

        const SettingsGroupTitle(title: "About"),
        SettingsListItem(
          icon: Icons.info_outline,
          label: "About Harmony",
          subtitle:
          "Harmony is the successor to HiOSMobile -- the app is now based on Flutter, so is adaptive and cross-platform.\nThis app is much faster and easier to maintain than HiOSMobile and HiOSMobile Lite, so we can bring new features to you faster!",
          onTap: () {}, //
          isFirstItem: true,
          isLastItem: true,
        ),
      ],
    );
  }
}
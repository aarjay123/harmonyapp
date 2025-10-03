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
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = '${info.version}+${info.buildNumber}';
      });
    }
  }

  final String _latestUpdateUrl = 'https://github.com/aarjay123/harmonyapp/releases/latest';
  final String _autoUpdateUrl = 'https://hienterprises.github.io/harmony/autoupdate';
  final String _discordUrl = 'https://discord.gg/EDykxqwy';

  Future<void> _launchExternalUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch the website.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageTemplate(
      title: "Updates",
      children: [
        // --- Update Harmony Group ---
        const SettingsGroupTitle(title: "Update Harmony"),
        SettingsListItem(
          icon: Icons.download_rounded,
          label: "Download from GitHub",
          subtitle: "Get the latest version from our official releases page.",
          onTap: () => _launchExternalUrl(context, _latestUpdateUrl),
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.update_rounded,
          label: "Set Up Auto-Updates",
          subtitle: "Visit our site to learn how to get automatic updates on Android.",
          onTap: () => _launchExternalUrl(context, _autoUpdateUrl),
          isLastItem: true,
        ),

        // --- Notifications Group ---
        const SettingsGroupTitle(title: "Stay Informed"),
        SettingsListItem(
          icon: Icons.notifications_active_rounded,
          label: "Join our Discord",
          subtitle: "Get notified every time we release a new update.",
          onTap: () => _launchExternalUrl(context, _discordUrl),
          isFirstItem: true,
          isLastItem: true,
        ),

        // --- Version Information Group ---
        const SettingsGroupTitle(title: "Version Information"),
        SettingsListItem(
          icon: Icons.new_releases_rounded,
          label: "What's New?",
          subtitle: "See the official release notes for the latest version.",
          onTap: () => _launchExternalUrl(context, _latestUpdateUrl),
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.info_rounded,
          label: "Current Version",
          subtitle: "You are running version $_version",
          // This item is purely informational, so it has no onTap action.
          // The UI component will automatically hide the chevron arrow.
          isLastItem: true,
        ),

        // --- About Group ---
        const SettingsGroupTitle(title: "About"),
        SettingsListItem(
          icon: Icons.info_outline,
          label: "About Harmony",
          subtitle: "Harmony is the successor to HiOSMobile -- the app is now based on Flutter, so is adaptive and cross-platform.\nThis app is much faster and easier to maintain than HiOSMobile and HiOSMobile Lite, so we can bring new features to you faster!",
          isFirstItem: true,
          isLastItem: true,
        ),
      ],
    );
  }
}
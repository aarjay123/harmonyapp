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

    final groups = [
      _UpdatesGroup(
        title: "Update Harmony",
        items: [
          _UpdatesItem(
            icon: Icons.download_rounded,
            label: "Manually Update Harmony",
            subtitle:
            "Download the latest app installer file.\n1. Tap here, then tap the installer matching your OS.\n2. Install the update how you usually would.",
            onTap: () => _launchExternalUrl(context, _latestUpdateUrl),
          ),
          _UpdatesItem(
            icon: Icons.info_rounded,
            label: "This version: $_version",
            subtitle: null,
            onTap: () {}, // no action, but needed for InkWell
          ),
          _UpdatesItem(
            icon: Icons.update_rounded,
            label: "Auto-Update Harmony on Android",
            subtitle: "Learn how to update Harmony on Android automatically on our website.",
            onTap: () {}, // no action, but needed for InkWell
          ),
        ],
      ),
      _UpdatesGroup(
          title: "Update notifications and more",
          items: [
            _UpdatesItem(
              icon: Icons.notifications_active_rounded,
              label: "Update Notifications",
              subtitle: "Join our Discord server to get notified every time we update Harmony.",
              onTap: () => _launchExternalUrl(context, _discordUrl), // no action, but needed for InkWell
            ),
            _UpdatesItem(
              icon: Icons.new_releases_rounded,
              label: "What's New?",
              subtitle: null,
              onTap: () => _launchExternalUrl(context, _latestUpdateUrl),
            ),
          ],
      ),
      _UpdatesGroup(
        title: "About",
        items: [
          _UpdatesItem(
            icon: Icons.info_outline,
            label: "About Harmony",
            subtitle:
            "Harmony is the successor to HiOSMobile -- the app is now based on Flutter, so is adaptive and cross-platform.\nThis app is much faster and easier to maintain than HiOSMobile and HiOSMobile Lite, so we can bring new features to you faster!",
            onTap: () {}, // no action, but needed for InkWell
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Updates"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // Consistent padding
        child: ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, groupIndex) {
            final group = groups[groupIndex];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step 2: Use the shared SettingsGroupTitle widget
                SettingsGroupTitle(title: group.title),
                // Items in the group
                Column(
                  children: List.generate(group.items.length, (itemIndex) {
                    final itemData = group.items[itemIndex]; // Renamed for clarity
                    final isFirstItem = itemIndex == 0;
                    final isLastItem = itemIndex == group.items.length - 1;

                    // Step 3: Use the shared SettingsListItem widget and RETURN it
                    return SettingsListItem(
                      icon: itemData.icon,
                      label: itemData.label,
                      subtitle: itemData.subtitle,
                      onTap: itemData.onTap,
                      isFirstItem: isFirstItem,
                      isLastItem: isLastItem,
                      // No 'trailing' widget passed, so chevron will appear if onTap is not null
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _UpdatesGroup {
  final String title;
  final List<_UpdatesItem> items;

  _UpdatesGroup({
    required this.title,
    required this.items,
  });
}

class _UpdatesItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  _UpdatesItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });
}
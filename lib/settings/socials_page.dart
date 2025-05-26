import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../settings_ui_components.dart';

class SocialsPage extends StatelessWidget {
  const SocialsPage({super.key});

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
      _SocialsGroup(
        title: "The Highland Cafe™ Enterprises",
        items: [
          _SocialsItem(
            icon: Icons.facebook_rounded,
            label: "Facebook",
            onTap: () => _launchExternalUrl(context, 'https://www.facebook.com/profile.php?id=100095224335357'),
          ),
          _SocialsItem(
            icon: Icons.camera_alt_rounded,
            label: "Instagram",
            onTap: () => _launchExternalUrl(context, 'https://instagram.com/thehighlandcafe'),
          ),
          _SocialsItem(
            icon: Icons.forum_rounded,
            label: "Threads",
            onTap: () => _launchExternalUrl(context, 'https://www.threads.net/@thehighlandcafe'),
          ),
        ],
      ),
      _SocialsGroup(
        title: "HiDev",
        items: [
          _SocialsItem(
            icon: Icons.facebook_rounded,
            label: "Facebook",
            onTap: () => _launchExternalUrl(context, 'https://www.facebook.com/profile.php?id=61558122144435'),
          ),
          _SocialsItem(
            icon: Icons.camera_alt_rounded,
            label: "Instagram",
            onTap: () => _launchExternalUrl(context, 'https://www.instagram.com/nuggetdev/'),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Socials"),
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

class _SocialsGroup {
  final String title;
  final List<_SocialsItem> items;

  _SocialsGroup({
    required this.title,
    required this.items,
  });
}

class _SocialsItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  _SocialsItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });
}
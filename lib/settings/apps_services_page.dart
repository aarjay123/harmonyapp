import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../settings_ui_components.dart';

class AppsServicesPage extends StatelessWidget {
  const AppsServicesPage({super.key});

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
      _AppsServicesGroup(
        title: "Recommended",
        items: [
          _AppsServicesItem(
            icon: Icons.music_note_rounded,
            label: "HiOSMusic",
            subtitle: "This is our brand new music app for Android. Your music, your vibe.",
            onTap: () => _launchExternalUrl(context, 'https://github.com/aarjay123/hiosmusic'),
          ),
          _AppsServicesItem(
            icon: Icons.stars_rounded,
            label: "HiRewards",
            subtitle:
            "Wanting to earn rewards for visiting your favourite brands by The Highland Cafe™? No probs, as you can now download HiRewards on your smartphone!",
            onTap: () => _launchExternalUrl(context, 'https://sites.google.com/view/hirewards'),
          ),
          _AppsServicesItem(
            icon: Icons.dashboard_customize_rounded,
            label: "Other software by HiDev",
            subtitle: "Take a look at other great apps, software, and services also by HiDev!",
            onTap: () => _launchExternalUrl(context, 'https://sites.google.com/view/nuggetdev'),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Apps & Services"),
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

class _AppsServicesGroup {
  final String title;
  final List<_AppsServicesItem> items;

  _AppsServicesGroup({
    required this.title,
    required this.items,
  });
}

class _AppsServicesItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  _AppsServicesItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });
}
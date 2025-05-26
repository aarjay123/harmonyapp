import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../settings_ui_components.dart';

class WebsitesPage extends StatelessWidget {
  const WebsitesPage({super.key});

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
      _WebsitesGroup(
        title: "Official websites",
        items: [
          _WebsiteItem(
            icon: Icons.business_rounded,
            label: "The Highland Cafe™ Enterprises",
            subtitle: "Official website for The Highland Cafe™ Enterprises.",
            onTap: () => _launchExternalUrl(context, 'https://hienterprises.github.io'),
          ),
          _WebsiteItem(
            icon: Icons.restaurant_rounded,
            label: "The Highland Cafe™",
            subtitle: "Official website for The Highland Cafe™.",
            onTap: () => _launchExternalUrl(context, 'https://hienterprises.github.io/hicafe/home'),
          ),
          _WebsiteItem(
            icon: Icons.developer_mode_rounded,
            label: "HiDev",
            subtitle: "Official website for HiDev.",
            onTap: () => _launchExternalUrl(context, 'https://sites.google.com/view/nuggetdev'),
          ),
          _WebsiteItem(
            icon: Icons.dashboard_rounded,
            label: "Harmony Website",
            subtitle: "Official website for the Harmony apps.",
            onTap: () => _launchExternalUrl(context, 'https://hienterprises.github.io/harmony/home'),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Websites"),
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

class _WebsitesGroup {
  final String title;
  final List<_WebsiteItem> items;

  _WebsitesGroup({
    required this.title,
    required this.items,
  });
}

class _WebsiteItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  _WebsiteItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });
}
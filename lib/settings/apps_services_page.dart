import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
      appBar: AppBar(title: const Text("Apps & Services")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, groupIndex) {
            final group = groups[groupIndex];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    group.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                  ),
                ),
                Column(
                  children: List.generate(group.items.length, (index) {
                    final isFirst = index == 0;
                    final isLast = index == group.items.length - 1;
                    final item = group.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Material(
                        color: colorScheme.primaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: isFirst ? const Radius.circular(16) : const Radius.circular(5),
                            bottom: isLast ? const Radius.circular(16) : const Radius.circular(5),
                          ),
                          //side: BorderSide(color: colorScheme.outline),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: item.onTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              crossAxisAlignment: item.subtitle != null
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.center,
                              children: [
                                Icon(item.icon, color: colorScheme.primary),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.label,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                      if (item.subtitle != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          item.subtitle!,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

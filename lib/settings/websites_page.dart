import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
      appBar: AppBar(title: const Text("Websites")),
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
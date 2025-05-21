import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
          _SocialItem(
            icon: Icons.facebook_rounded,
            label: "Facebook",
            onTap: () => _launchExternalUrl(context, 'https://www.facebook.com/profile.php?id=100095224335357'),
          ),
          _SocialItem(
            icon: Icons.camera_alt_rounded,
            label: "Instagram",
            onTap: () => _launchExternalUrl(context, 'https://www.instagram.com/thehighlandcafe/'),
          ),
          _SocialItem(
            icon: Icons.forum_rounded,
            label: "Threads",
            onTap: () => _launchExternalUrl(context, 'https://www.threads.net/@thehighlandcafe'),
          ),
        ],
      ),
      _SocialsGroup(
        title: "HiDev",
        items: [
          _SocialItem(
            icon: Icons.facebook_rounded,
            label: "Facebook",
            onTap: () => _launchExternalUrl(context, 'https://www.facebook.com/profile.php?id=61558122144435'),
          ),
          _SocialItem(
            icon: Icons.camera_alt_rounded,
            label: "Instagram",
            onTap: () => _launchExternalUrl(context, 'https://www.instagram.com/nuggetdev/'),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Socials")),
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
                              children: [
                                Icon(item.icon, color: colorScheme.primary),
                                const SizedBox(width: 16),
                                Text(
                                  item.label,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
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

class _SocialsGroup {
  final String title;
  final List<_SocialItem> items;

  _SocialsGroup({
    required this.title,
    required this.items,
  });
}

class _SocialItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _SocialItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

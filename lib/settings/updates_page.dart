import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  // URLs
  final String _latestUpdateUrl = 'https://github.com/aarjay123/harmonyapp/releases/latest';

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
            icon: Icons.download,
            label: "Download Harmony Update",
            subtitle:
            "Download the latest app installer file.\n1. Tap here, then tap the installer matching your OS.\n2. Install the update how you usually would.",
            onTap: () => _launchExternalUrl(context, _latestUpdateUrl),
          ),
          _UpdatesItem(
            icon: Icons.info,
            label: "This version: 3.0.0",
            subtitle: null,
            onTap: () {}, // no action, but needed for InkWell
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
      appBar: AppBar(title: const Text("Updates")),
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

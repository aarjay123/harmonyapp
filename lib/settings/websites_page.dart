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

    return SettingsPageTemplate(
      title: "Websites",
      children: [
        const SettingsGroupTitle(title: "Official websites"),
        SettingsListItem(
          icon: Icons.business_rounded,
          label: "The Highland Cafe™ Enterprises",
          onTap: () => _launchExternalUrl(context, 'https://hienterprises.github.io'),
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.restaurant_rounded,
          label: "The Highland Cafe™",
          onTap: () => _launchExternalUrl(context, 'https://hienterprises.github.io/hicafe/home'),
        ),
        SettingsListItem(
          icon: Icons.developer_mode_rounded,
          label: "nuggetdev",
          onTap: () => _launchExternalUrl(context, 'https://hienterprises.github.io/nuggetdev/home'),
        ),
        SettingsListItem(
          icon: Icons.dashboard_rounded,
          label: "Harmony",
          onTap: () => _launchExternalUrl(context, 'https://hienterprises.github.io/harmony/home'),
          isLastItem: true,
        ),
      ],
    );
  }
}
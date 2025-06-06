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

    return SettingsPageTemplate(
      title: "Socials",
      children: [
        const SettingsGroupTitle(title: "The Highland Cafe™ Enterprises"),
        SettingsListItem(
          icon: Icons.facebook_rounded,
          label: "Facebook",
          onTap: () => _launchExternalUrl(context, 'https://www.facebook.com/profile.php?id=100095224335357'),
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.camera_alt_rounded,
          label: "Instagram",
          onTap: () => _launchExternalUrl(context, 'https://instagram.com/thehighlandcafe'),
        ),
        SettingsListItem(
          icon: Icons.forum_rounded,
          label: "Threads",
          onTap: () => _launchExternalUrl(context, 'https://www.threads.net/@thehighlandcafe'),
          isLastItem: true,
        ),
        const SettingsGroupTitle(title: "HiDev"),
        SettingsListItem(
          icon: Icons.facebook_rounded,
          label: "Facebook",
          onTap: () => _launchExternalUrl(context, 'https://www.facebook.com/profile.php?id=61558122144435'),
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.camera_alt_rounded,
          label: "Instagram",
          onTap: () => _launchExternalUrl(context, 'https://www.instagram.com/nuggetdev/'),
          isLastItem: true,
        ),
      ],
    );
  }
}
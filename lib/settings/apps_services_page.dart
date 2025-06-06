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

    return SettingsPageTemplate(
      title: "Apps & Services",
      children: [
        const SettingsGroupTitle(title: "Recommended"),
        SettingsListItem(
          icon: Icons.music_note_rounded,
          label: "HiOSMusic",
          subtitle: "This is our brand new music app for Android. Your music, your vibe.",
          onTap: () => _launchExternalUrl(context, 'https://github.com/aarjay123/hiosmusic'),
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.stars_rounded,
          label: "HiRewards",
          subtitle: "Wanting to earn rewards for visiting your favourite brands by The Highland Cafe™? No probs, as you can now download HiRewards on your smartphone!",
          onTap: () => _launchExternalUrl(context, 'https://sites.google.com/view/hirewards'),
        ),
        SettingsListItem(
          icon: Icons.dashboard_customize_rounded,
          label: "Other software by HiDev",
          subtitle: "Take a look at other great apps, software, and services also by HiDev!",
          onTap: () => _launchExternalUrl(context, 'https://sites.google.com/view/nuggetdev'),
          isLastItem: true,
        ),
      ],
    );
  }
}
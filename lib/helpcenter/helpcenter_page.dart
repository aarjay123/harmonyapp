import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs

import '../settings_ui_components.dart'; // Assuming it's in the parent directory

import 'articles/app_tutorial_page.dart';
import 'articles/restaurant_help_page.dart';
import 'articles/hotel_help_page.dart';
import 'articles/roomkey_help_page.dart';
import 'articles/customer_support_page.dart';
import 'articles/internet_help_page.dart';
import 'articles/updates_help_page.dart';
import 'articles/terms_conditions_page.dart';
import 'articles/app_feedback_info_page.dart';

// --- Main Help Center Page ---
class HelpcenterPage extends StatelessWidget {
  const HelpcenterPage({super.key});

  Future<void> _launchExternalUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsPageTemplate(
      title: "Help",
      children: [
        const SettingsGroupTitle(title: "Getting Started"),
        SettingsListItem(
          icon: Icons.help_outline_rounded,
          label: "App Tutorial",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppTutorialPage()),
          ),
          isFirstItem: true,
          isLastItem: true,
        ),

        const SettingsGroupTitle(title: "General"),
        SettingsListItem(
          icon: Icons.restaurant_rounded,
          label: "Restaurant",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RestaurantHelpPage())),
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.hotel_rounded,
          label: "Hotel",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HotelHelpPage())),
        ),
        SettingsListItem(
          icon: Icons.key_rounded,
          label: "Room Key",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomKeyHelpPage())),
        ),
        SettingsListItem(
          icon: Icons.support_agent_rounded,
          label: "Customer Support",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerSupportPage())),
        ),
        SettingsListItem(
          icon: Icons.wifi_rounded,
          label: "Internet",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InternetHelpPage())),
        ),
        SettingsListItem(
          icon: Icons.update_rounded,
          label: "Updates",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdatesHelpPage())),
          isLastItem: true,
        ),

        const SettingsGroupTitle(title: "More"),
        SettingsListItem(
          icon: Icons.new_releases_rounded,
          label: "Coming Soon",
          onTap: () => _launchExternalUrl(context, 'https://hienterprises.github.io/harmony/comingsoon'),
          isFirstItem: true,
        ),
        SettingsListItem(
          icon: Icons.info_outline,
          label: "Terms & Conditions",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsPage())),
        ),
        SettingsListItem(
          icon: Icons.feedback_rounded,
          label: "App Feedback",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppFeedbackInfoPage())),
          isLastItem: true,
        ),
      ],
    );
  }
}
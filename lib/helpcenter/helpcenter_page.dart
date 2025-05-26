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

// --- Data Model for Help Topics ---
class HelpTopic {
  final IconData iconData;
  final String title;
  final Widget? pageBuilder; // A widget builder for the detail page
  final String? externalUrl;
  final VoidCallback? customOnTap;

  HelpTopic({
    required this.iconData,
    required this.title,
    this.pageBuilder,
    this.externalUrl,
    this.customOnTap,
  }) : assert(pageBuilder != null || externalUrl != null || customOnTap != null,
  'HelpTopic must have a pageBuilder, externalUrl, or customOnTap');
}

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

  static final List<HelpTopic> _tutorialTopics = [
    HelpTopic(
      iconData: Icons.smartphone_rounded,
      title: "App Tutorial",
      pageBuilder: const AppTutorialPage(), // Using specific placeholder
    ),
  ];

  static final List<HelpTopic> _generalTopics = [
    HelpTopic(
      iconData: Icons.restaurant_rounded,
      title: "Restaurant",
      pageBuilder: const RestaurantHelpPage(), // Using specific placeholder
    ),
    HelpTopic(
      iconData: Icons.hotel_rounded,
      title: "Hotel",
      pageBuilder: const HotelHelpPage(), // Using specific placeholder
    ),
    HelpTopic(
      iconData: Icons.vpn_key_rounded,
      title: "Room Key",
      pageBuilder: const RoomKeyHelpPage(), // Using specific placeholder
    ),
    HelpTopic(
      iconData: Icons.support_agent_rounded,
      title: "Customer Support",
      pageBuilder: const CustomerSupportPage(), // Using specific placeholder
    ),
    HelpTopic(
      iconData: Icons.language_rounded,
      title: "Internet",
      pageBuilder: const InternetHelpPage(), // Using specific placeholder
    ),
    HelpTopic(
      iconData: Icons.update_rounded,
      title: "Updates",
      pageBuilder: const UpdatesHelpPage(), // Using specific placeholder
    ),
  ];

  static final List<HelpTopic> _moreTopics = [
    HelpTopic(
      iconData: Icons.new_releases_rounded,
      title: "Coming Soon",
      externalUrl: "https://hienterprises.github.io/harmony/comingsoon",
      // pageBuilder: const ComingSoonInfoPage(), // Or a placeholder if you want a page before launching URL
    ),
    HelpTopic(
      iconData: Icons.description_rounded,
      title: "Terms & Conditions",
      pageBuilder: const TermsConditionsPage(), // Using specific placeholder
    ),
    HelpTopic(
      iconData: Icons.feedback_rounded,
      title: "App Feedback",
      pageBuilder: const AppFeedbackInfoPage(), // Using specific placeholder
    ),
  ];

  Widget _buildHelpCategory({
    required BuildContext context,
    required String title,
    required List<HelpTopic> topics,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsGroupTitle(title: title),
        const SizedBox(height: 8),
        Column(
          children: List.generate(topics.length, (index) {
            final topic = topics[index];
            final isFirst = index == 0;
            final isLast = index == topics.length - 1;

            return SettingsListItem(
              icon: topic.iconData,
              label: topic.title,
              onTap: () {
                if (topic.customOnTap != null) {
                  topic.customOnTap!();
                } else if (topic.externalUrl != null && topic.externalUrl!.isNotEmpty) {
                  _launchExternalUrl(context, topic.externalUrl!);
                } else if (topic.pageBuilder != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => topic.pageBuilder!),
                  );
                }
              },
              isFirstItem: isFirst,
              isLastItem: isLast,
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),
      ),
      backgroundColor: colorScheme.surface,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHelpCategory(
            context: context,
            title: "Tutorial",
            topics: _tutorialTopics,
          ),
          const SizedBox(height: 16),
          _buildHelpCategory(
            context: context,
            title: "General",
            topics: _generalTopics,
          ),
          const SizedBox(height: 16),
          _buildHelpCategory(
            context: context,
            title: "More",
            topics: _moreTopics,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
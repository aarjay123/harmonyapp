import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // --- Modern Header ---
          SliverAppBar.large(
            title: Text('Privacy Policy', style: TextStyle(color: colorScheme.onSurface)),
            backgroundColor: colorScheme.surface,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.teal.withOpacity(0.2), // Matching the teal theme from SettingsPage
                      colorScheme.surface,
                    ],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Icon(
                      Icons.privacy_tip_rounded,
                      size: 80,
                      color: Colors.teal.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- Content ---
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Last Updated Info
                Text(
                  "Last Updated: April 8th, 2025",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Intro Text
                Text(
                  'This Privacy Policy outlines the collection, use, and protection of personal information when you use HiOSMobile for Android, and HiOSMobile for Web, open-source applications created by HiOSMobile and The Highland Cafe™️ Enterprises ("we," "our," or "us"). By downloading, installing, or using these applications, you agree to the practices described in this policy.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Section 1
                _buildSectionTitle(context, "1. Information We Collect"),
                _buildParagraph(context, "1.1 Personal Information:", "We do not collect information about you. The only personal information that is collected is collected by The Highland Cafe™️, and is information you give us, via our in-app forms. GitHub, who we use to host HiOSWebCore, does not collect any information at all."),
                _buildParagraph(context, "1.2 Non-Personal Information:", "We don't collect any non-personal information."),

                // Section 2
                const SizedBox(height: 16),
                _buildSectionTitle(context, "2. How We Use Your Information"),
                _buildParagraph(context, "2.1 Personal Information:", "We may use your personal information for the following purposes:"),
                _buildBulletPoint(context, "To communicate with you, respond to inquiries, and provide customer support."),
                _buildBulletPoint(context, "To send you important updates, notifications, and information related to the apps."),
                _buildBulletPoint(context, "To improve our services and apps."),
                const SizedBox(height: 8),
                _buildParagraph(context, "2.2 Non-Personal Information:", "Again, we don't collect any non-personal information."),

                // Section 3
                const SizedBox(height: 16),
                _buildSectionTitle(context, "3. Sharing Your Information"),
                Text(
                  "We do not sell, trade, or rent your personal information to third parties. However, we may share your information in the following circumstances:",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(context, "With your explicit consent."),
                _buildBulletPoint(context, "If required by law or in response to a valid legal request."),
                _buildBulletPoint(context, "To protect our rights, privacy, safety, or property or that of our users or the public."),
                _buildBulletPoint(context, "In connection with the sale, merger, or acquisition of all or part of our company, as permitted by law."),

                // Section 4
                const SizedBox(height: 16),
                _buildSectionTitle(context, "4. Data Security"),
                Text(
                  "We are committed to protecting your information and employ reasonable security measures to safeguard your data. However, no method of transmission over the internet or electronic storage is 100% secure, so we cannot guarantee absolute security.",
                  style: theme.textTheme.bodyMedium,
                ),

                // Section 5
                const SizedBox(height: 16),
                _buildSectionTitle(context, "5. Your Choices"),
                Text("You have the following rights regarding your personal information:", style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                _buildBulletPoint(context, "To speak to us via customer support to do a search on your data, then go on from there on your request."),
                _buildBulletPoint(context, "To request the deletion of your personal information, via above method."),

                // Section 6
                const SizedBox(height: 16),
                _buildSectionTitle(context, "6. Changes to this Privacy Policy"),
                Text(
                  "We may update this Privacy Policy as needed to reflect changes in our practices or for other operational, legal, or regulatory reasons. Any changes will be posted on this page, and the \"Last Updated\" date will be revised accordingly.",
                  style: theme.textTheme.bodyMedium,
                ),

                // Section 7
                const SizedBox(height: 16),
                _buildSectionTitle(context, "7. Contact Us"),
                Text(
                  "If you have questions or concerns about this Privacy Policy or our data practices, please contact us via the HiOSMobile app at Help > Customer Support, or via our Customer Support page.",
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 40),
                Center(
                  child: Text(
                    "This is the end of the HiOSMobile Privacy Policy.",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.underline,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

                // Scroll to top button (functionally just a spacer here as scrolling is natural)
                Center(
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      // Scroll to top logic if needed, or just pop
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_upward_rounded),
                    label: const Text("Back to Settings"),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String label, String content) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
          children: [
            TextSpan(text: "$label ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
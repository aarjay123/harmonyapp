import 'package:flutter/material.dart';
// It seems url_launcher might be needed if "Install Messenger" button is implemented later
// import 'package:url_launcher/url_launcher.dart';

class CustomerSupportPage extends StatelessWidget {
  const CustomerSupportPage({super.key});

  static const double _contentMaxWidth = 768.0;

  // Helper widget to build each instruction step
  Widget _buildInstructionStep(BuildContext context, String number, List<InlineSpan> content) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: theme.textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
                children: content,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for a section card
  Widget _buildHelpSectionCard(BuildContext context, String title, List<Widget> instructionSteps) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            ...instructionSteps,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // const double iconSize = 18.0; // Not used directly in this page's list items

    // Common style for bold text within instructions
    final boldStyle = TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSecondaryContainer);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Support"),
      ),
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.support_agent_rounded, // Icon for Support
                        size: 36,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Support",
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Unsure on how get support from us? Take a look below.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Creating a Facebook Account Section
                  _buildHelpSectionCard(
                    context,
                    "Creating a Facebook Account",
                    [
                      _buildInstructionStep(context, "1", [
                        const TextSpan(text: "First, go to "),
                        TextSpan(text: "facebook.com", style: boldStyle),
                        const TextSpan(text: "."),
                      ]),
                      _buildInstructionStep(context, "2", [
                        const TextSpan(text: "Next, tap "),
                        TextSpan(text: "Create New Account", style: boldStyle),
                        const TextSpan(text: " and follow the steps to create and verify your Facebook account."),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Messaging Us Section
                  _buildHelpSectionCard(
                    context,
                    "Messaging Us",
                    [
                      _buildInstructionStep(context, "1", [
                        const TextSpan(text: "Tap the "),
                        TextSpan(text: "Customer Support", style: boldStyle),
                        const TextSpan(text: " option in the Help Center."),
                      ]),
                      _buildInstructionStep(context, "2", [
                        const TextSpan(text: "You'll come to a page called "),
                        TextSpan(text: "Customer Support", style: boldStyle),
                        const TextSpan(text: ". If you don't have Messenger installed, install it from the button on the page. Otherwise, tap "),
                        TextSpan(text: "Contact Us", style: boldStyle),
                        const TextSpan(text: "."),
                        // The <br> tag is not directly convertible. We can add more vertical space if needed.
                      ]),
                      // If more space is needed after step 2, a SizedBox can be added here.
                      // const SizedBox(height: 8.0),
                    ],
                  ),
                  const SizedBox(height: 16), // Padding at the end of the list
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
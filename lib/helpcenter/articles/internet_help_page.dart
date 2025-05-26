import 'package:flutter/material.dart';

class InternetHelpPage extends StatelessWidget {
  const InternetHelpPage({super.key});

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

  // Helper widget for the main content card
  Widget _buildHelpContentCard(BuildContext context, List<Widget> children) {
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
          children: children,
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
        title: const Text("WiFi and Internet Help"),
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
                        Icons.wifi_rounded, // Icon for WiFi
                        size: 36,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "WiFi and Internet",
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
                    "Need help with our internet? Look below.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Instructions Section
                  _buildHelpContentCard(
                    context,
                    [
                      _buildInstructionStep(context, "1", [
                        const TextSpan(text: "First, open the "),
                        TextSpan(text: "Settings", style: boldStyle),
                        const TextSpan(text: " app from your launcher."),
                      ]),
                      _buildInstructionStep(context, "2", [
                        const TextSpan(text: "Then, click on "),
                        TextSpan(text: "WiFi", style: boldStyle),
                        const TextSpan(text: " or "),
                        TextSpan(text: "Network and Internet", style: boldStyle),
                        const TextSpan(text: "**."),
                      ]),
                      _buildInstructionStep(context, "3", [
                        const TextSpan(text: "Click on the WiFi network called "),
                        TextSpan(text: "The Highland Cafe™️ WiFi", style: boldStyle),
                        const TextSpan(text: " and follow steps to create/sign into your HiAccount details to connect!"),
                      ]),
                      const SizedBox(height: 16.0), // Corresponds to mt-4
                      Text(
                        "*WiFi-enabled device required.",
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSecondaryContainer.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        "**WiFi settings' location depends on brand of phone you use.",
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSecondaryContainer.withOpacity(0.8)),
                      ),
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
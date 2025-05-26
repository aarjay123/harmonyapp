import 'package:flutter/material.dart';

class UpdatesHelpPage extends StatelessWidget {
  const UpdatesHelpPage({super.key});

  static const double _contentMaxWidth = 768.0;

  // Helper widget to build each instruction step with an optional inline icon
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
    const double iconSize = 18.0; // Size for inline icons

    // Common style for bold text within instructions
    final boldStyle = TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSecondaryContainer);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Updates Help"),
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
                        Icons.system_update_rounded, // Icon for Updates
                        size: 36,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Updates",
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
                    "Unsure on how to update Harmony? Take a look below.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Updating Harmony Section
                  _buildHelpSectionCard(
                    context,
                    "Updating Harmony",
                    [
                      _buildInstructionStep(context, "1", [
                        const TextSpan(text: "First, tap the "),
                        WidgetSpan(child: Icon(Icons.more_vert_rounded, size: iconSize, color: colorScheme.onSecondaryContainer)),
                        const TextSpan(text: " icon on the top bar of the main Harmony screen."),
                      ]),
                      _buildInstructionStep(context, "2", [
                        const TextSpan(text: "Tap the "),
                        TextSpan(text: "Settings", style: boldStyle),
                        WidgetSpan(child: Icon(Icons.settings_rounded, size: iconSize, color: colorScheme.onSecondaryContainer)),
                        const TextSpan(text: " option."),
                      ]),
                      _buildInstructionStep(context, "3", [
                        const TextSpan(text: "Then tap the "),
                        TextSpan(text: "Updates", style: boldStyle),
                        WidgetSpan(child: Icon(Icons.system_update_rounded, size: iconSize, color: colorScheme.onSecondaryContainer)),
                        const TextSpan(text: " option."),
                      ]),
                      _buildInstructionStep(context, "4", [
                        const TextSpan(text: "Then tap the "),
                        TextSpan(text: "Manually Update Harmony", style: boldStyle),
                        WidgetSpan(child: Icon(Icons.system_update_rounded, size: iconSize, color: colorScheme.onSecondaryContainer)),
                        const TextSpan(text: " option."),
                      ]),
                      _buildInstructionStep(context, "5", [
                        const TextSpan(text: "Then, the latest version of Harmony will download as a .apk file."),
                      ]),
                      _buildInstructionStep(context, "6", [
                        const TextSpan(text: "Once downloaded, tap on the file name in your notifications. Google Play will prompt you to scan the app, tap "),
                        TextSpan(text: "Scan", style: boldStyle),
                        const TextSpan(text: ", and then "),
                        TextSpan(text: "Update.", style: boldStyle),
                      ]),
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
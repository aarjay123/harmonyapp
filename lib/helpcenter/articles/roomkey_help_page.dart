import 'package:flutter/material.dart';

class RoomKeyHelpPage extends StatelessWidget {
  const RoomKeyHelpPage({super.key});

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

  // Helper widget for a section card (though this page only has one main content section)
  Widget _buildHelpSectionCard(BuildContext context, List<Widget> instructionSteps) {
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
          children: instructionSteps, // Directly use the instruction steps
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const double iconSize = 18.0; // Size for inline icons

    // Common style for bold text within instructions (if needed)
    // final boldStyle = TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSecondaryContainer);


    return Scaffold(
      appBar: AppBar(
        title: const Text("Room Key Help"),
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
                        Icons.key_rounded, // Icon for Room Key
                        size: 36,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Room Key",
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
                    "Unsure on how to use our digital Room Key? Take a look below.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Instructions Section
                  _buildHelpSectionCard(
                    context,
                    [
                      _buildInstructionStep(context, "1", [
                        const TextSpan(text: "First, tap the "),
                        WidgetSpan(child: Icon(Icons.key_rounded, size: iconSize, color: colorScheme.onSecondaryContainer)),
                        const TextSpan(text: " icon on the bottom navigation bar."),
                      ]),
                      _buildInstructionStep(context, "2", [
                        const TextSpan(text: "Now you can unlock your room."),
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
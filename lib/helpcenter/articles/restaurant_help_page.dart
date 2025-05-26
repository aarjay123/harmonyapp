import 'package:flutter/material.dart';

class RestaurantHelpPage extends StatelessWidget {
  const RestaurantHelpPage({super.key});

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
    // Common style for regular text within instructions (to ensure RichText inherits correctly)
    final defaultTextStyle = theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSecondaryContainer) ?? const TextStyle();


    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant Help"),
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
                        Icons.restaurant_rounded,
                        size: 36,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Restaurant",
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
                    "Unsure on how to do certain things with this app for visiting The Highland Cafe™️? Take a look below.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Booking a Table Section
                  _buildHelpSectionCard(
                    context,
                    "Booking a Table",
                    [
                      _buildInstructionStep(context, "1", [
                        const TextSpan(text: "First, tap the "),
                        WidgetSpan(child: Icon(Icons.restaurant_rounded, size: iconSize, color: colorScheme.onSecondaryContainer)),
                        const TextSpan(text: " icon on the bottom navigation bar."),
                      ]),
                      _buildInstructionStep(context, "2", [
                        const TextSpan(text: "Tap "),
                        TextSpan(text: "'Your HiCafe™ Visit'", style: boldStyle),
                        const TextSpan(text: "."),
                      ]),
                      _buildInstructionStep(context, "3", [
                        const TextSpan(text: "Tap the "),
                        WidgetSpan(child: Icon(Icons.menu_rounded, size: iconSize, color: colorScheme.onSecondaryContainer)),
                        const TextSpan(text: " icon at the top right, and choose "),
                        TextSpan(text: "Booking", style: boldStyle),
                        const TextSpan(text: "."),
                      ]),
                      _buildInstructionStep(context, "4", [
                        const TextSpan(text: "Fill in the form to book a table at The Highland Cafe™️."),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Viewing our Menus Section
                  _buildHelpSectionCard(
                    context,
                    "Viewing our Menus",
                    [
                      _buildInstructionStep(context, "1", [
                        const TextSpan(text: "First, tap the "),
                        WidgetSpan(child: Icon(Icons.restaurant_rounded, size: iconSize, color: colorScheme.onSecondaryContainer)),
                        const TextSpan(text: " icon on the bottom navigation bar."),
                      ]),
                      _buildInstructionStep(context, "2", [
                        const TextSpan(text: "Tap "),
                        TextSpan(text: "'Your HiCafe™ Visit'", style: boldStyle),
                        const TextSpan(text: "."),
                      ]),
                      _buildInstructionStep(context, "3", [
                        const TextSpan(text: "Tap the "),
                        WidgetSpan(child: Icon(Icons.menu_rounded, size: iconSize, color: colorScheme.onSecondaryContainer)),
                        const TextSpan(text: " icon at the top right, and choose "),
                        TextSpan(text: "Menus", style: boldStyle),
                        const TextSpan(text: "."),
                      ]),
                      _buildInstructionStep(context, "4", [
                        const TextSpan(text: "You can now scroll through our menus as you please."),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ordering Food Section
                  _buildHelpSectionCard(
                    context,
                    "Ordering Food",
                    [
                      _buildInstructionStep(context, "1", [
                        const TextSpan(text: "First, tap the "),
                        WidgetSpan(child: Icon(Icons.restaurant_rounded, size: iconSize, color: colorScheme.onSecondaryContainer)),
                        const TextSpan(text: " icon on the bottom navigation bar."),
                      ]),
                      _buildInstructionStep(context, "2", [
                        const TextSpan(text: "Tap "),
                        TextSpan(text: "'Your HiCafe™ Visit'", style: boldStyle),
                        const TextSpan(text: "."),
                      ]),
                      _buildInstructionStep(context, "3", [
                        const TextSpan(text: "Tap the "),
                        WidgetSpan(child: Icon(Icons.menu_rounded, size: iconSize, color: colorScheme.onSecondaryContainer)),
                        const TextSpan(text: " icon at the top right, and choose "),
                        TextSpan(text: "Order", style: boldStyle),
                        const TextSpan(text: "."),
                      ]),
                      _buildInstructionStep(context, "4", [
                        const TextSpan(text: "Fill in the form to order food to your table at The Highland Cafe™️."),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Checking-in to Breakfast Section
                  _buildHelpSectionCard(
                    context,
                    "Checking-in to Breakfast",
                    [
                      _buildInstructionStep(context, "1", [
                        const TextSpan(text: "First, tap the "),
                        WidgetSpan(child: Icon(Icons.restaurant_rounded, size: iconSize, color: colorScheme.onSecondaryContainer)),
                        const TextSpan(text: " icon on the bottom navigation bar."),
                      ]),
                      _buildInstructionStep(context, "2", [
                        const TextSpan(text: "Tap "),
                        TextSpan(text: "'Breakfast Check-in'", style: boldStyle),
                        const TextSpan(text: "."),
                      ]),
                      _buildInstructionStep(context, "3", [
                        const TextSpan(text: "Fill in the form with your details to check-in to breakfast."),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Viewing our Locations Section
                  _buildHelpSectionCard(
                    context,
                    "Viewing our Locations",
                    [
                      _buildInstructionStep(context, "1", [
                        const TextSpan(text: "First, tap the "),
                        WidgetSpan(child: Icon(Icons.restaurant_rounded, size: iconSize, color: colorScheme.onSecondaryContainer)),
                        const TextSpan(text: " icon on the bottom navigation bar."),
                      ]),
                      _buildInstructionStep(context, "2", [
                        const TextSpan(text: "Tap "),
                        TextSpan(text: "'Locations'", style: boldStyle),
                        const TextSpan(text: "."),
                      ]),
                      _buildInstructionStep(context, "3", [
                        const TextSpan(text: "Zoom in on each location on the map, and look as you please."),
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
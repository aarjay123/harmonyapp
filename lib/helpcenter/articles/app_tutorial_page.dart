import 'package:flutter/material.dart';

// --- Native App Tutorial Page ---
class AppTutorialPage extends StatelessWidget {
  const AppTutorialPage({super.key});

  static const double _contentMaxWidth = 768.0; // For desktop-like constrained width
  final String _tutorialGifUrl = 'https://thehighlandcafe.github.io/hioswebcore/assets/media/tutorial.gif';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("App Tutorial"), // AppBar title for this specific page
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
                crossAxisAlignment: CrossAxisAlignment.start, // Align header content to the start
                children: [
                  // Header Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_rounded, // Matching HTML icon
                        size: 36,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded( // Use Expanded to allow title to wrap if needed
                        child: Text(
                          "Navigation Tutorial",
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
                    "Unsure on how to navigate and use HiOSMobile? Take a look at the animations below.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main Content Card
                  Card(
                    elevation: 0,
                    color: colorScheme.secondaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    clipBehavior: Clip.antiAlias, // Ensures content respects border radius
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        // Changed crossAxisAlignment to center for the card's content
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Navigating the main pages",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center, // Centered text
                          ),
                          const SizedBox(height: 16.0),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0), // Rounded corners for the GIF
                            child: Image.network(
                              _tutorialGifUrl,
                              fit: BoxFit.contain, // Adjust fit as needed
                              // Consider adding a fixed height or AspectRatio if the GIF's aspect ratio is known
                              // height: 300, // Example fixed height
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                                );
                              },
                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                return Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image_rounded, size: 48, color: colorScheme.onSurfaceVariant),
                                        const SizedBox(height: 8),
                                        Text('Could not load tutorial animation.', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            "*More updated animations coming soon*",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: colorScheme.onSecondaryContainer.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center, // Centered text
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
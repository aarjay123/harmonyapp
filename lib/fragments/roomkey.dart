import 'package:flutter/material.dart';

class RoomKeyPage extends StatelessWidget {
  const RoomKeyPage({super.key});

  // Define a max width for desktop-like content presentation
  static const double _contentMaxWidth = 768.0;
  final String _nfcGifUrl = 'https://cdn.dribbble.com/users/1489841/screenshots/11131159/nfc.gif';


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // appBar: AppBar( // No separate AppBar, title is in the page content
      //   title: const Text('Room Key'),
      // ),
      backgroundColor: colorScheme.surface, // Consistent page background
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0), // Overall vertical padding
        child: Center( // Center the constrained content
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
            child: Padding( // Overall horizontal padding
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section - Styled like RestaurantPage
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, top: 8.0), // Adjusted top padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.key_rounded, // Icon for Room Key
                              size: 36,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Room Key',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        // No subtitle in the HTML for this main header, so omitted.
                      ],
                    ),
                  ),

                  // Main Content Card (GIF and instruction)
                  Card(
                    elevation: 0,
                    color: colorScheme.secondaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    clipBehavior: Clip.antiAlias, // To ensure image respects border radius
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect( // Clip the image to have rounded corners
                            borderRadius: BorderRadius.circular(12.0), // Slightly smaller radius than card
                            child: Image.network(
                              _nfcGifUrl,
                              fit: BoxFit.contain, // Or BoxFit.cover depending on desired effect
                              height: 200, // Adjust height as needed
                              // Add error and loading builders for Image.network
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                return Container(
                                  height: 200,
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image_rounded, size: 48, color: colorScheme.onSurfaceVariant),
                                        const SizedBox(height: 8),
                                        Text('Could not load image', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Your Key',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Tap your phone on your room\'s doorhandle to unlock.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSecondaryContainer.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 1.0), // Minimal spacing to join cards visually

                  // NFC Information Card
                  Card(
                    elevation: 0,
                    color: colorScheme.secondaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7), size: 20),
                          const SizedBox(width: 8),
                          Expanded( // Use Expanded to allow text to wrap if needed
                            child: Text(
                              'You need NFC to be switched on to use your digital room key.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSecondaryContainer.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
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
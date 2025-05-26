import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// A simple page to display a webview in fullscreen
// Included here for self-containment of the example.
// In a real project, move this to a shared utility file if used by multiple pages.
// class FullscreenWebViewPage extends StatelessWidget {
//   final String url;
//   final String title;

//   const FullscreenWebViewPage({super.key, required this.url, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(title)),
//       body: InAppWebView(
//         initialUrlRequest: URLRequest(url: WebUri(url)),
//         initialSettings: InAppWebViewSettings(
//           javaScriptEnabled: true,
//         ),
//       ),
//     );
//   }
// }

class RestaurantLocationsPage extends StatelessWidget {
  const RestaurantLocationsPage({super.key});

  // TODO: Replace with your actual Google Maps embed URL
  // The URL from the HTML 'https://www.google.com/maps/d/embed?mid=1uifQD-IGknh0jPlri0xvZJ6WTnUOt2k&ehbc=2E312F&noprof=1' is not a valid embed URL.
  // Example: "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d...etc"
  // Using a placeholder pointing to Carnforth for now.
  final String _mapEmbedUrl = 'https://www.google.com/maps/d/embed?mid=1uifQD-IGknh0jPlri0xvZJ6WTnUOt2k&ehbc=2E312F&noprof=1';


  // Define a max width for desktop-like content presentation
  static const double _contentMaxWidth = 768.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Locations'),
        // Back button is automatically added by Navigator
      ),
      backgroundColor: colorScheme.surface, // Consistent page background
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0), // Only vertical padding for scroll view
        child: Center( // Center the constrained content
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
            child: Padding( // Horizontal padding applied after constraining width
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section - styled like restaurant.dart page header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, top: 8.0), // Adjusted top padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pin_drop_rounded, // Icon for locations
                              size: 36,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Locations',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Wanting to find all our branches? Look below at the map.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card for the map - styled like hicafe_page.dart content cards
                  Card(
                    elevation: 0,
                    color: colorScheme.secondaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), // Padding inside the card
                      child: SizedBox(
                        height: 800, // Adjust height as needed for the map
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0), // Rounded corners for the webview
                          child: InAppWebView(
                            key: ValueKey(_mapEmbedUrl),
                            initialUrlRequest: URLRequest(url: WebUri(_mapEmbedUrl)),
                            initialSettings: InAppWebViewSettings(
                              javaScriptEnabled: true,
                              // You might need other settings depending on the map provider
                            ),
                          ),
                        ),
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
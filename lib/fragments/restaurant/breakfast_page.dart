import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// A simple page to display a webview in fullscreen
// Included here for self-containment of the example.
// In a real project, move this to a shared utility file.
class FullscreenWebViewPage extends StatelessWidget {
  final String url;
  final String title;

  const FullscreenWebViewPage({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          // Add any other settings you need for fullscreen view
        ),
      ),
    );
  }
}

class BreakfastCheckInPage extends StatelessWidget {
  const BreakfastCheckInPage({super.key});

  final String _breakfastFormUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSdjJ0yto-VHoTjDtkYlbvr4XjI2wwd_XN-g7vuRP9aNwF1wwg/viewform?embedded=true';
  // For the fullscreen button, we typically remove "?embedded=true" if the form supports it,
  // or link to a non-embedded version if available.
  // If the same URL works well fullscreen, we can use it.
  // For Google Forms, removing embedded=true often just shows the standard GForms page.
  final String _breakfastFormFullscreenUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSdjJ0yto-VHoTjDtkYlbvr4XjI2wwd_XN-g7vuRP9aNwF1wwg/viewform';


  // Define a max width for desktop-like content presentation, similar to hicafe_page
  static const double _contentMaxWidth = 768.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Breakfast Check-In'),
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
                              Icons.egg_alt_rounded, // Icon for breakfast
                              size: 36,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Check-In to Breakfast',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use the form below to check-in to breakfast.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card for the button and webview - styled like hicafe_page.dart
                  Card(
                    elevation: 0,
                    color: colorScheme.secondaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.fullscreen_rounded, color: colorScheme.onPrimary),
                            label: Text('Open Form Fullscreen', style: TextStyle(color: colorScheme.onPrimary)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullscreenWebViewPage(
                                    url: _breakfastFormFullscreenUrl, // Use non-embedded for fullscreen
                                    title: 'Breakfast Check-In Form',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 800, // Adjust height as needed for the form
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: InAppWebView(
                                key: ValueKey(_breakfastFormUrl),
                                initialUrlRequest: URLRequest(url: WebUri(_breakfastFormUrl)),
                                initialSettings: InAppWebViewSettings(
                                  javaScriptEnabled: true,
                                  transparentBackground: true, // If form background is handled by Google Forms
                                ),
                              ),
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
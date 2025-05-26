import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  static const double _contentMaxWidth = 768.0;
  final String _termsConditionsUrl = 'https://drive.google.com/file/d/1q0gKTgao5euscmQUM3rmSUl3HG2ejXE0/preview';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
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
                        Icons.info_outline_rounded, // Icon for Terms & Conditions
                        size: 36,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Terms and Conditions",
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
                    "Take a look at our T's and C's below.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Content Card with WebView
                  Card(
                    elevation: 0,
                    color: colorScheme.secondaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    clipBehavior: Clip.antiAlias, // Ensures content respects border radius
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), // Padding inside the card
                      child: SizedBox(
                        height: 800, // Adjust height as needed for the document viewer
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0), // Rounded corners for the webview
                          child: InAppWebView(
                            key: ValueKey(_termsConditionsUrl),
                            initialUrlRequest: URLRequest(url: WebUri(_termsConditionsUrl)),
                            initialSettings: InAppWebViewSettings(
                              javaScriptEnabled: true,
                              // Add other settings if needed for Google Drive preview
                            ),
                            // Optional: Add loading and error handling for the webview
                            onLoadStart: (controller, url) {
                              // You could show a loading indicator
                            },
                            onLoadStop: (controller, url) {
                              // You could hide a loading indicator
                            },
                            onLoadError: (controller, url, code, message) {
                              // Handle error, e.g., show a message
                              debugPrint("WebView Error for $url: $code, $message");
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Padding at the end
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
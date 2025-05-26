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
        ),
      ),
    );
  }
}

class CafeFiestaPage extends StatefulWidget {
  const CafeFiestaPage({super.key});

  @override
  State<CafeFiestaPage> createState() => _CafeFiestaPageState();
}

class _CafeFiestaPageState extends State<CafeFiestaPage> with TickerProviderStateMixin {
  late TabController _tabController;

  final String _menuIframeUrl = 'https://drive.google.com/file/d/1v6kWr813fKLS25FprgLu0sklpXpjB2Gy/preview';
  final String _menuFullscreenUrl = 'https://drive.google.com/file/d/1v6kWr813fKLS25FprgLu0sklpXpjB2Gy/view';

  final String _orderIframeUrl = 'https://forms.office.com/Pages/ResponsePage.aspx?id=DQSIkWdsW0yxEjajBLZtrQAAAAAAAAAAAAYAABORJhBUQkdCUEhHOTJDMUpIRVVKRzBWNjdNVVQ3QS4u&embed=true';
  final String _orderFullscreenUrl = 'https://forms.office.com/Pages/ResponsePage.aspx?id=DQSIkWdsW0yxEjajBLZtrQAAAAAAAAAAAAYAABORJhBUQkdCUEhHOTJDMUpIRVVKRzBWNjdNVVQ3QS4u';


  // Define a max width for desktop-like content presentation
  static const double _contentMaxWidth = 768.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Menu, Order
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildContentSection({
    required String sectionTitle, // e.g., "Menu" or "Order"
    required String iframeUrl,
    required String fullscreenUrl,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card for the button and webview
                Card(
                  elevation: 0,
                  color: colorScheme.secondaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            sectionTitle, // Dynamic title for the section
                            style: theme.textTheme.headlineSmall?.copyWith( // Changed from titleLarge for consistency
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.fullscreen_rounded, color: colorScheme.onPrimary),
                          label: Text('Open ${sectionTitle} Fullscreen', style: TextStyle(color: colorScheme.onPrimary)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullscreenWebViewPage(url: fullscreenUrl, title: sectionTitle),
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
                          height: 800, // Adjusted height for better form/menu visibility
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: InAppWebView(
                              key: ValueKey(iframeUrl),
                              initialUrlRequest: URLRequest(url: WebUri(iframeUrl)),
                              initialSettings: InAppWebViewSettings(
                                javaScriptEnabled: true,
                                transparentBackground: true,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CafeFiesta™️'),
      ),
      backgroundColor: colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section - Styled like other pages
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.coffee_maker_rounded, // Icon for CafeFiesta
                          size: 36,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'CafeFiesta',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome to the artisan coffee shop chain by The Highland Cafe™️.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Pill Navigation TabBar
          Material(
            color: colorScheme.surface,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _contentMaxWidth / 1.5),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: colorScheme.onPrimaryContainer,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      color: colorScheme.primaryContainer,
                    ),
                    splashBorderRadius: BorderRadius.circular(24.0),
                    dividerHeight: 0.0,
                    tabs: const [
                      Tab(text: 'Menu'),
                      Tab(text: 'Order'),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Menu Tab
                _buildContentSection(
                  sectionTitle: 'Menu',
                  iframeUrl: _menuIframeUrl,
                  fullscreenUrl: _menuFullscreenUrl,
                ),
                // Order Tab
                _buildContentSection(
                  sectionTitle: 'Order',
                  iframeUrl: _orderIframeUrl,
                  fullscreenUrl: _orderFullscreenUrl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
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

class HotelPage extends StatefulWidget {
  const HotelPage({super.key});

  @override
  State<HotelPage> createState() => _HotelPageState();
}

class _HotelPageState extends State<HotelPage> with TickerProviderStateMixin {
  late TabController _tabController;

  final String _bookRoomFormUrl = 'https://forms.office.com/Pages/ResponsePage.aspx?id=DQSIkWdsW0yxEjajBLZtrQAAAAAAAAAAAAYAABORJhBUNzlCNkROOVc3UzJCTFQ1UVpWQ0pHQk9YSS4u&embed=true';
  final String _bookRoomFullscreenUrl = 'https://forms.office.com/Pages/ResponsePage.aspx?id=DQSIkWdsW0yxEjajBLZtrQAAAAAAAAAAAAYAABORJhBUNzlCNkROOVc3UzJCTFQ1UVpWQ0pHQk9YSS4u';

  final String _checkInFormUrl = 'https://forms.office.com/Pages/ResponsePage.aspx?id=DQSIkWdsW0yxEjajBLZtrQAAAAAAAAAAAAYAABORJhBUQkJBVkZFSDhCOVJDMjdBRFQ2Sjc3NEM5MS4u&embed=true';
  final String _checkInFullscreenUrl = 'https://forms.office.com/Pages/ResponsePage.aspx?id=DQSIkWdsW0yxEjajBLZtrQAAAAAAAAAAAAYAABORJhBUQkJBVkZFSDhCOVJDMjdBRFQ2Sjc3NEM5MS4u';

  final String _checkOutFormUrl = 'https://forms.office.com/Pages/ResponsePage.aspx?id=DQSIkWdsW0yxEjajBLZtrQAAAAAAAAAAAAYAABORJhBUMjdUUDRPMzg2OE9GOTRaQlNMUjJSUFdONS4u&embed=true';
  final String _checkOutFullscreenUrl = 'https://forms.office.com/Pages/ResponsePage.aspx?id=DQSIkWdsW0yxEjajBLZtrQAAAAAAAAAAAAYAABORJhBUMjdUUDRPMzg2OE9GOTRaQlNMUjJSUFdONS4u';


  // Define a max width for desktop-like content presentation
  static const double _contentMaxWidth = 768.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Book, Arriving, Leaving
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildHotelContentSection({
    required String sectionTitle,
    required String sectionSubtitle,
    required String iframeUrl,
    required String fullscreenUrl,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Each tab's content is now wrapped in its own SingleChildScrollView
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
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
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          sectionTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (sectionSubtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            sectionSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSecondaryContainer.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.fullscreen_rounded, color: colorScheme.onPrimary),
                        label: Text('Open Form Fullscreen', style: TextStyle(color: colorScheme.onPrimary)),
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
                        height: 800,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column( // Main layout is now a Column
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section - Styled like RestaurantPage
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
                          Icons.hotel_rounded, // Icon for Hotel
                          size: 36,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Hotel',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Staying at weB&B? Select an option from below to get started.',
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
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
                      Tab(text: 'Book'),
                      Tab(text: 'Arriving'),
                      Tab(text: 'Leaving'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // TabBarView wrapped in Expanded to take remaining space
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              // Prevent TabBarView from handling swipes if children scroll
              children: [
                // Book Tab
                _buildHotelContentSection(
                  sectionTitle: 'Book a Room',
                  sectionSubtitle: 'Book a room at weB&B below.',
                  iframeUrl: _bookRoomFormUrl,
                  fullscreenUrl: _bookRoomFullscreenUrl,
                ),
                // Arriving Tab
                _buildHotelContentSection(
                  sectionTitle: 'Arriving',
                  sectionSubtitle: 'Welcome! Check in below. :)',
                  iframeUrl: _checkInFormUrl,
                  fullscreenUrl: _checkInFullscreenUrl,
                ),
                // Leaving Tab
                _buildHotelContentSection(
                  sectionTitle: 'Leaving',
                  sectionSubtitle: 'Thank you for staying with us! Check out below. :)',
                  iframeUrl: _checkOutFormUrl,
                  fullscreenUrl: _checkOutFullscreenUrl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
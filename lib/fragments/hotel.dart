import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/gestures.dart'; // Import for GestureRecognizers
import 'package:flutter/foundation.dart' show Factory;

// A simple page to display a webview in fullscreen
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

  // This method now builds the content for each tab, including its own header
  Widget _buildTabContentWithHeader({
    required String tabTitle,         // e.g., "Book a Room"
    required IconData tabIcon,        // Icon for this specific tab's header
    required String tabSubtitle,      // Subtitle for this specific tab's header
    required String iframeUrl,
    required String fullscreenUrl,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tab-Specific Header Section
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top:8.0), // Added top padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(tabIcon, size: 32, color: colorScheme.primary), // Slightly larger icon
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                              tabTitle,
                              style: theme.textTheme.headlineSmall?.copyWith( // Changed to headlineSmall
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              )
                          ),
                        ),
                      ],
                    ),
                    if (tabSubtitle.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 44.0), // Indent subtitle to align with text after icon
                        child: Text(
                          tabSubtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    ]
                  ],
                ),
              ),
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
                      ElevatedButton.icon(
                        icon: Icon(Icons.fullscreen_rounded, color: colorScheme.onPrimary),
                        label: Text('Open Form Fullscreen', style: TextStyle(color: colorScheme.onPrimary)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullscreenWebViewPage(url: fullscreenUrl, title: tabTitle),
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
                        height: 500,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: InAppWebView(
                            key: ValueKey(iframeUrl),
                            initialUrlRequest: URLRequest(url: WebUri(iframeUrl)),
                            initialSettings: InAppWebViewSettings(
                              javaScriptEnabled: true,
                              transparentBackground: true,
                            ),
                            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                              Factory<VerticalDragGestureRecognizer>(
                                    () => VerticalDragGestureRecognizer(),
                              ),
                            },
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: Material(
              color: colorScheme.surface,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildTabContentWithHeader(
                  tabTitle: 'Book a Room',
                  tabIcon: Icons.calendar_month_rounded,
                  tabSubtitle: 'Book a room at weB&B below.',
                  iframeUrl: _bookRoomFormUrl,
                  fullscreenUrl: _bookRoomFullscreenUrl,
                ),
                _buildTabContentWithHeader(
                  tabTitle: 'Arriving',
                  tabIcon: Icons.login_rounded,
                  tabSubtitle: 'Welcome! Check in below. :)',
                  iframeUrl: _checkInFormUrl,
                  fullscreenUrl: _checkInFullscreenUrl,
                ),
                _buildTabContentWithHeader(
                  tabTitle: 'Leaving',
                  tabIcon: Icons.logout_rounded,
                  tabSubtitle: 'Thank you for staying with us! Check out below. :)',
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
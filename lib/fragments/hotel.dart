import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart' show Factory;

// NOTE: In a real project, these shared widgets would be moved to their own files
// in a 'widgets' or 'common' directory to avoid code duplication.

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

// This custom WebView widget handles its own state (loading, errors)
// and includes pull-to-refresh functionality.
class InteractiveWebView extends StatefulWidget {
  final String url;
  const InteractiveWebView({super.key, required this.url});

  @override
  State<InteractiveWebView> createState() => _InteractiveWebViewState();
}

class _InteractiveWebViewState extends State<InteractiveWebView> {
  late InAppWebViewController _webViewController;
  PullToRefreshController? _pullToRefreshController;
  double _progress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Initialization is moved to didChangeDependencies to safely access context.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the controller here if it hasn't been already.
    _pullToRefreshController ??= PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Theme.of(context).colorScheme.primary,
      ),
      onRefresh: () async {
        if (mounted) {
          await _webViewController.reload();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        InAppWebView(
          key: ValueKey(widget.url),
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          pullToRefreshController: _pullToRefreshController,
          onProgressChanged: (controller, progress) {
            setState(() {
              _progress = progress / 100;
              if (progress == 100) {
                _pullToRefreshController?.endRefreshing();
              }
            });
          },
          onLoadError: (controller, url, code, message) {
            _pullToRefreshController?.endRefreshing();
            setState(() => _hasError = true);
          },
          onLoadHttpError: (controller, url, statusCode, description) {
            _pullToRefreshController?.endRefreshing();
            setState(() => _hasError = true);
          },
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
          },
        ),
        if (_progress < 1.0 && !_hasError)
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        if (_hasError)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('Failed to load content', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Please check your internet connection and try again.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _progress = 0;
                      });
                      _webViewController.reload();
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
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

  static const double _contentMaxWidth = 800.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // REFACTORED: This widget builds the content for each tab.
  Widget _buildTabContent({
    required String title,
    required String subtitle,
    required String iframeUrl,
    required String fullscreenUrl,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, size: 28, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.fullscreen_rounded),
                label: const Text('Open Fullscreen'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => FullscreenWebViewPage(url: fullscreenUrl, title: title),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  elevation: 0,
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  clipBehavior: Clip.antiAlias,
                  child: InteractiveWebView(url: iframeUrl),
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
    // REBUILT with NestedScrollView to fix scrolling issues and improve layout.
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: const Text('Hotel'),
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.calendar_month_rounded), text: 'Book'),
                  Tab(icon: Icon(Icons.login_rounded), text: 'Arriving'),
                  Tab(icon: Icon(Icons.logout_rounded), text: 'Leaving'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTabContent(
              title: 'Book a Room',
              subtitle: 'Book a room at weB&B below.',
              iframeUrl: _bookRoomFormUrl,
              fullscreenUrl: _bookRoomFullscreenUrl,
              icon: Icons.calendar_month_rounded,
            ),
            _buildTabContent(
              title: 'Arriving',
              subtitle: 'Welcome! Check in below. :)',
              iframeUrl: _checkInFormUrl,
              fullscreenUrl: _checkInFullscreenUrl,
              icon: Icons.login_rounded,
            ),
            _buildTabContent(
              title: 'Leaving',
              subtitle: 'Thank you for staying with us! Check out below. :)',
              iframeUrl: _checkOutFormUrl,
              fullscreenUrl: _checkOutFullscreenUrl,
              icon: Icons.logout_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

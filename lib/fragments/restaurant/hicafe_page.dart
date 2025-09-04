import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/gestures.dart';
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
          // Add any other settings you need for fullscreen view
        ),
      ),
    );
  }
}

// IMPROVED: This custom WebView widget now handles its own state (loading, errors)
// and includes pull-to-refresh functionality.
class InteractiveWebView extends StatefulWidget {
  final String url;
  const InteractiveWebView({super.key, required this.url});

  @override
  State<InteractiveWebView> createState() => _InteractiveWebViewState();
}

class _InteractiveWebViewState extends State<InteractiveWebView> {
  late InAppWebViewController _webViewController;
  // FIX: Changed from 'late' to nullable to be initialized in didChangeDependencies.
  PullToRefreshController? _pullToRefreshController;
  double _progress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Initialization is moved to didChangeDependencies to safely access context.
  }

  // FIX: This is the correct lifecycle method to access context for initialization.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the controller here if it hasn't been already.
    _pullToRefreshController ??= PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Theme.of(context).colorScheme.primary,
      ),
      onRefresh: () async {
        // Check if the widget is still in the tree before interacting with the controller.
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
            setState(() {
              _hasError = true;
            });
          },
          onLoadHttpError: (controller, url, statusCode, description) {
            _pullToRefreshController?.endRefreshing();
            setState(() {
              _hasError = true;
            });
          },
          // This is crucial for enabling scrolling within nested scroll views
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer(),
            ),
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
                  Text(
                    'Failed to load content',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your internet connection and try again.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
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

class HiCafePage extends StatefulWidget {
  const HiCafePage({super.key});

  @override
  State<HiCafePage> createState() => _HiCafePageState();
}

class _HiCafePageState extends State<HiCafePage> with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _menusTabController;

  final String _bookTableFormUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSfeP-cO7te979Dc-QRmUsBwQTzIojYRtg7Yx3OufiiUcn2r2g/viewform?embedded=true';
  final String _orderFoodFormUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSfGzW5su4bVmpeRVGRbDDeudfZkvhbyuXi-pySKLW4qA8WnaA/viewform?embedded=true';

  final Map<String, String> _menuUrls = {
    'Normal': 'https://drive.google.com/file/d/1asnkFiTAX-bancBcS094ge9XE3Q-Bn3d/preview',
    'Worldwide': 'https://drive.google.com/file/d/1ZTnLTPCGjV0MdHNjTP9JJBSW_WdtSm8i/preview',
    'Pizza': 'https://drive.google.com/file/d/1YezhyJuuUg-sghImzB-zWn-wGnI6l8Ww/preview',
    'Gastro': 'https://drive.google.com/file/d/1iHoe-pBMn0niY9R2IoZgYmhgXLaz7Mrz/preview',
  };

  static const double _contentMaxWidth = 800.0;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this);
    _menusTabController = TabController(length: _menuUrls.length, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _menusTabController.dispose();
    super.dispose();
  }

  // REFACTORED: This widget builds the content for the Book and Order tabs.
  Widget _buildFormPage({
    required String title,
    required String subtitle,
    required String iframeUrl,
    required IconData titleIcon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final String fullscreenUrl = iframeUrl.replaceAll("?embedded=true", "");

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(titleIcon, size: 28, color: colorScheme.primary),
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
              Card(
                elevation: 0,
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.fullscreen_rounded),
                        label: const Text('Open Fullscreen'),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => FullscreenWebViewPage(url: fullscreenUrl, title: title),
                          ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: InteractiveWebView(url: iframeUrl),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // REFACTORED: This builds the content for a single menu in the Menus tab.
  Widget _buildMenuContent(String menuName, String menuUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: Card(
            elevation: 0,
            color: Colors.transparent, // Let the InteractiveWebView handle its background
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            child: InteractiveWebView(url: menuUrl),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // REBUILT with NestedScrollView to fix scrolling issues and improve layout.
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: const Text('Your HiCafe™ Visit'),
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              bottom: TabBar(
                controller: _mainTabController,
                tabs: const [
                  Tab(icon: Icon(Icons.table_restaurant_rounded), text: 'Book'),
                  Tab(icon: Icon(Icons.menu_book_rounded), text: 'Menus'),
                  Tab(icon: Icon(Icons.delivery_dining_rounded), text: 'Order'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _mainTabController,
          children: [
            // Book a Table Tab
            _buildFormPage(
              title: 'Book a Table',
              subtitle: 'Fill in the form to book, we\'ll reply within an hour.',
              iframeUrl: _bookTableFormUrl,
              titleIcon: Icons.table_restaurant_rounded,
            ),
            // Menus Tab
            Column(
              children: [
                const SizedBox(height: 8),
                TabBar(
                  controller: _menusTabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  tabs: _menuUrls.keys.map((String key) => Tab(text: key)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _menusTabController,
                    children: _menuUrls.entries.map((entry) {
                      return _buildMenuContent(entry.key, entry.value);
                    }).toList(),
                  ),
                ),
              ],
            ),
            // Food Ordering Tab
            _buildFormPage(
              title: 'Food Ordering',
              subtitle: 'Order the food you would like below.',
              iframeUrl: _orderFoodFormUrl,
              titleIcon: Icons.delivery_dining_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
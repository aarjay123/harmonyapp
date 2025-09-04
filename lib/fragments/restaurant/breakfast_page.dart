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


class BreakfastCheckInPage extends StatelessWidget {
  const BreakfastCheckInPage({super.key});

  final String _breakfastFormUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSdjJ0yto-VHoTjDtkYlbvr4XjI2wwd_XN-g7vuRP9aNwF1wwg/viewform?embedded=true';
  final String _breakfastFormFullscreenUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSdjJ0yto-VHoTjDtkYlbvr4XjI2wwd_XN-g7vuRP9aNwF1wwg/viewform';

  static const double _contentMaxWidth = 768.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Breakfast Check-In'),
      ),
      backgroundColor: colorScheme.surface,
      // REFACTORED: Use a Column with an Expanded WebView to fix scrolling issues.
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0), // Padding for the whole content area
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.egg_alt_rounded, size: 36, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        // Wrap title in flexible to prevent overflow on small screens
                        Flexible(
                          child: Text(
                            'Check-In to Breakfast',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
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
                const SizedBox(height: 24),

                // Fullscreen button
                ElevatedButton.icon(
                  icon: const Icon(Icons.fullscreen_rounded),
                  label: const Text('Open Form Fullscreen'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullscreenWebViewPage(
                          url: _breakfastFormFullscreenUrl,
                          title: 'Breakfast Check-In Form',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  ),
                ),
                const SizedBox(height: 16),

                // The WebView is now expanded to fill the remaining space
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: Colors.transparent, // Let WebView handle its own background
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    clipBehavior: Clip.antiAlias,
                    child: InteractiveWebView(url: _breakfastFormUrl),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

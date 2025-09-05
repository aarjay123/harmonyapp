import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart' show Factory;
import 'dart:math'; // Required for the Random() class

// NOTE: This InteractiveWebView is a self-contained helper widget.
// It's the same one used on your restaurant pages, included here for completeness.
// It adds loading, error, and pull-to-refresh functionality.
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
                  Text('Failed to load video', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
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


/// A dashboard widget that displays a random YouTube video using a web embed.
class YoutubeCard extends StatefulWidget {
  const YoutubeCard({super.key});

  @override
  State<YoutubeCard> createState() => _YoutubeCardState();
}

class _YoutubeCardState extends State<YoutubeCard> {
  // Using a ValueNotifier to trigger rebuilds of the WebView when the URL changes.
  late ValueNotifier<String> _currentVideoUrl;
  final _random = Random();

  final List<String> _videoIds = const [
    '7By-gcfB_iY', // Welcome to WorstEastern
    'cr_hByEBpFg', // MyLad 2.0E
    'mL6l87z3E7g', // MyPhone
    '3YNGaQyFSRE', // MyTV
    'e0L0zvhrlM8', // MyLad 2.0D
    'o50a0E7ibBg', // MyLap
  ];

  // Helper to create the standard YouTube embed URL.
  String _getEmbedUrl(String videoId) {
    // Parameters to hide controls, related videos, etc., for a cleaner look.
    return 'https://www.youtube.com/embed/$videoId?autoplay=0&controls=1&showinfo=0&rel=0';
  }

  @override
  void initState() {
    super.initState();
    // Select an initial random video ID and create the initial URL.
    final initialVideoId = _videoIds[_random.nextInt(_videoIds.length)];
    _currentVideoUrl = ValueNotifier(_getEmbedUrl(initialVideoId));
  }

  /// Selects a new random video from the list and updates the URL.
  void _playNextRandomVideo() {
    String currentId = Uri.parse(_currentVideoUrl.value).pathSegments.last;
    String newVideoId = currentId;

    if (_videoIds.length > 1) {
      while (newVideoId == currentId) {
        newVideoId = _videoIds[_random.nextInt(_videoIds.length)];
      }
    }

    // Update the ValueNotifier, which will cause the listening widget to rebuild.
    _currentVideoUrl.value = _getEmbedUrl(newVideoId);
  }

  @override
  void dispose() {
    _currentVideoUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.surfaceVariant,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.play_circle_fill_rounded, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Text(
                  "Videos",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // FIXED: Removed the Flexible widget that was causing the layout assertion error.
          // The AspectRatio widget is sufficient to size the player correctly within the Column.
          ValueListenableBuilder<String>(
            valueListenable: _currentVideoUrl,
            builder: (context, videoUrl, child) {
              // Using AspectRatio to maintain the 16:9 video format.
              return AspectRatio(
                aspectRatio: 16 / 9,
                child: InteractiveWebView(url: videoUrl),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "A random video from our curated list.",
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _playNextRandomVideo,
                  icon: const Icon(Icons.shuffle_rounded),
                  label: const Text("Play Another"),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


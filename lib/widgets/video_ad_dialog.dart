import 'dart:async';
import 'dart:math'; // Import the math library for the random number generator
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// A dialog that shows a random YouTube video ad and forces a wait time before skipping.
class VideoAdDialog extends StatefulWidget {
  // The action to perform after the user skips the ad.
  final VoidCallback onSkipped;

  const VideoAdDialog({super.key, required this.onSkipped});

  @override
  State<VideoAdDialog> createState() => _VideoAdDialogState();
}

class _VideoAdDialogState extends State<VideoAdDialog> {
  // The list of YouTube video IDs to choose from.
  static final List<String> _videoIds = const [
    '7By-gcfB_iY', // Welcome to WorstEastern
    'cr_hByEBpFg', // MyLad 2.0E
    'mL6l87z3E7g', // MyPhone
    '3YNGaQyFSRE', // MyTV
    'e0L0zvhrlM8', // MyLad 2.0D
    'o50a0E7ibBg', // MyLap
  ];

  // Helper to create the standard YouTube embed URL.
  String _getEmbedUrl(String videoId) {
    // Parameters to hide controls, related videos, etc., and enable autoplay.
    return 'https://www.youtube.com/embed/$videoId?autoplay=1&controls=0&showinfo=0&rel=0&iv_load_policy=3&modestbranding=1';
  }

  late String _videoAdUrl; // Will hold the randomly selected video URL
  late Timer _timer;
  int _secondsRemaining = 15;
  bool _canSkip = false;

  @override
  void initState() {
    super.initState();
    _selectRandomVideo();
    _startCountdown();
  }

  // New method to pick a random video from the list.
  void _selectRandomVideo() {
    final random = Random();
    final randomIndex = random.nextInt(_videoIds.length);
    final randomVideoId = _videoIds[randomIndex];
    _videoAdUrl = _getEmbedUrl(randomVideoId);
  }

  void _startCountdown() {
    // Start a periodic timer that fires every second.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        // When the countdown finishes, enable the skip button and stop the timer.
        if (mounted) {
          setState(() {
            _canSkip = true;
          });
        }
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Always cancel timers in dispose to prevent memory leaks.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use WillPopScope to prevent the user from closing the dialog with the back button.
    return WillPopScope(
      onWillPop: () async => false, // Prevents back-button dismissal
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600, // Constrain the width for a dialog-like appearance
          height: 450, // Constrain the height
          color: Colors.black,
          child: Column(
            children: [
              // The WebView takes up most of the space.
              Expanded(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(_videoAdUrl)),
                  initialSettings: InAppWebViewSettings(
                    // These settings are crucial for web autoplay to work.
                    mediaPlaybackRequiresUserGesture: false,
                    allowsInlineMediaPlayback: true,
                    iframeAllowFullscreen: true,
                  ),
                ),
              ),
              // The skip button and countdown timer section.
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // The skip button is only visible when _canSkip is true.
                    if (_canSkip)
                      ElevatedButton(
                        onPressed: () {
                          // Close the dialog first.
                          Navigator.of(context).pop();
                          // Then, execute the original action.
                          widget.onSkipped();
                        },
                        child: const Text("Skip Ad"),
                      )
                    else
                    // Otherwise, show the countdown timer.
                      Text(
                        "You can skip in $_secondsRemaining seconds...",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70),
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
}
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:math'; // Required for the Random() class

/// A dashboard widget that displays a random YouTube video from a predefined list.
class YoutubeCard extends StatefulWidget {
  const YoutubeCard({super.key});

  @override
  State<YoutubeCard> createState() => _YoutubeCardState();
}

class _YoutubeCardState extends State<YoutubeCard> {
  late YoutubePlayerController _controller;
  late String _currentVideoId;
  final _random = Random();

  // A predefined list of YouTube video IDs to choose from.
  final List<String> _videoIds = const [
    '7By-gcfB_iY', // Welcome to WorstEastern
    'cr_hByEBpFg', // MyLad 2.0E
    'mL6l87z3E7g', // MyPhone
    '3YNGaQyFSRE', // MyTV
    'e0L0zvhrlM8', // MyLad 2.0D
    'o50a0E7ibBg', // MyLap
  ];

  @override
  void initState() {
    super.initState();
    // Select an initial random video ID from the list.
    _currentVideoId = _videoIds[_random.nextInt(_videoIds.length)];

    // Initialize the controller with the randomly selected video.
    _controller = YoutubePlayerController(
      initialVideoId: _currentVideoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        forceHD: false,
        showLiveFullscreenButton: false,
      ),
    );
  }

  /// Selects a new random video from the list and loads it into the player.
  void _playNextRandomVideo() {
    String newVideoId = _currentVideoId;
    // Ensure the new video is different from the current one, if possible.
    if (_videoIds.length > 1) {
      while (newVideoId == _currentVideoId) {
        newVideoId = _videoIds[_random.nextInt(_videoIds.length)];
      }
    }

    // Update the state to reflect the new video ID and load it.
    if (mounted) {
      setState(() {
        _currentVideoId = newVideoId;
      });
      _controller.load(_currentVideoId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.play_circle_fill_rounded, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Text(
                  "Video Player",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // YouTube Player
          YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: colorScheme.primary,
              progressColors: ProgressBarColors(
                playedColor: colorScheme.primary,
                handleColor: colorScheme.primary,
              ),
              // The thumbnail updates to the new random video.
              thumbnail: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      YoutubePlayer.getThumbnail(
                        videoId: _currentVideoId,
                        quality: ThumbnailQuality.high,
                      ),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white.withOpacity(0.8),
                    size: 50,
                  ),
                ),
              ),
            ),
            builder: (context, player) {
              return player;
            },
          ),
          // "Play Another" button section
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


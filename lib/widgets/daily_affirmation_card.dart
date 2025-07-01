import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For local data persistence

/// A card widget that displays a daily affirmation or inspirational quote with persistence.
class DailyAffirmationCard extends StatefulWidget {
  const DailyAffirmationCard({super.key});

  @override
  State<DailyAffirmationCard> createState() => _DailyAffirmationCardState();
}

class _DailyAffirmationCardState extends State<DailyAffirmationCard> {
  // MODIFIED: Expanded the list of affirmations for more variety.
  final List<String> _affirmations = [
    "I am capable of achieving my goals.",
    "Every day is a new opportunity to grow and improve.",
    "I am surrounded by positivity and abundance.",
    "My potential is limitless.",
    "I choose joy and happiness today.",
    "I am grateful for all the good in my life.",
    "I trust my intuition and make wise decisions.",
    "I am strong, resilient, and brave.",
    "Challenges help me discover my inner strength.",
    "I radiate love and compassion.",
    "I am worthy of success and happiness.",
    "I believe in myself and my abilities.",
    "My mind is filled with positive thoughts.",
    "I am creating the life of my dreams.",
    "I release all negativity and embrace peace."
  ];
  String _currentAffirmation = ""; // Stores the affirmation currently displayed
  int _currentAffirmationIndex = 0; // Tracks the index of the current affirmation

  @override
  void initState() {
    super.initState();
    _loadAffirmationIndex(); // Load the last displayed affirmation index on initialization
  }

  /// Loads the last displayed affirmation index from SharedPreferences.
  Future<void> _loadAffirmationIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Retrieve the saved index, defaulting to 0 if not found.
      _currentAffirmationIndex = prefs.getInt('dailyAffirmationIndex') ?? 0;
      // Ensure the index is within bounds of the affirmations list.
      if (_currentAffirmationIndex >= _affirmations.length || _currentAffirmationIndex < 0) {
        _currentAffirmationIndex = 0;
      }
      _currentAffirmation = _affirmations[_currentAffirmationIndex]; // Set the current affirmation
    });
  }

  /// Saves the current affirmation index to SharedPreferences.
  Future<void> _saveAffirmationIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyAffirmationIndex', index);
  }

  /// Cycles to the next affirmation in the list and saves its index.
  void _getNewAffirmation() {
    setState(() {
      // Increment index and use modulo to loop back to the beginning of the list.
      _currentAffirmationIndex = (_currentAffirmationIndex + 1) % _affirmations.length;
      _currentAffirmation = _affirmations[_currentAffirmationIndex]; // Update displayed affirmation
      _saveAffirmationIndex(_currentAffirmationIndex); // Save the new index for persistence
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0, // Flat card design
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.secondaryContainer, // Uses secondary container color for differentiation
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Consistent internal padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row for the Daily Affirmation card
            Row(
              children: [
                Icon(Icons.star_half_rounded, color: colorScheme.onSecondaryContainer, size: 28),
                const SizedBox(width: 12),
                Text(
                  "Daily Affirmation",
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600
                  ),
                ),
                const Spacer(), // Pushes the refresh button to the end
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7)),
                  onPressed: _getNewAffirmation, // Triggers a new affirmation
                  tooltip: 'New Affirmation',
                )
              ],
            ),
            const SizedBox(height: 16), // Space below header

            // MODIFIED: Replaced the simple Text widget with a Stack and an AnimatedSwitcher
            // for a more visually appealing and dynamic presentation.
            Stack(
              children: [
                // Decorative background quote icon
                Positioned.fill(
                  child: Icon(
                    Icons.format_quote_rounded,
                    size: 100,
                    color: colorScheme.onSecondaryContainer.withOpacity(0.08),
                  ),
                ),
                // AnimatedSwitcher provides a smooth fade transition when the affirmation text changes.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500), // Duration of the fade animation
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    // Use a FadeTransition for the animation
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Center(
                    // The Key is crucial. AnimatedSwitcher uses it to detect when the child has changed.
                    key: ValueKey<String>(_currentAffirmation),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                      child: Text(
                        _currentAffirmation,
                        textAlign: TextAlign.center, // Center the text
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontStyle: FontStyle.italic, // Italicize for quote-like appearance
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
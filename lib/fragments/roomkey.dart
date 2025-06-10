// fragments/roomkey.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class RoomKeyPage extends StatefulWidget {
  const RoomKeyPage({super.key});

  @override
  State<RoomKeyPage> createState() => _RoomKeyPageState();
}

class _RoomKeyPageState extends State<RoomKeyPage> {
  // Define a max width for desktop-like content presentation
  static const double _contentMaxWidth = 450.0; // Slightly increased for better card proportion
  final String _nfcGifUrl = 'https://cdn.dribbble.com/users/1489841/screenshots/11131159/nfc.gif';

  // Placeholder data - in a real app, this would come from user session, booking details, etc.
  final String _hotelName = "weB&B by The Highland Cafe™️";
  final String _roomNumber = "305";
  final String _guestName = "John Smith"; // Placeholder

  // State variables for dates
  String _checkInDate = "";
  String _checkOutDate = "";

  @override
  void initState() {
    super.initState();
    _updateDates();
  }

  void _updateDates() {
    final now = DateTime.now();
    // Example: May 26, 2025 (e.g., Mon, Jun 10)
    final dateFormat = DateFormat('EEE, MMM d, y');

    _checkInDate = dateFormat.format(now);
    _checkOutDate = dateFormat.format(now.add(const Duration(days: 2))); // Check-out 2 days from now
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section - Kept as requested
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.key_rounded,
                        size: 36,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Room Key', // Title remains the same
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                          fontSize: 28, // Adjusted for a more compact header
                        ),
                      ),
                    ],
                  ),
                ),

                // Digital Key Card
                Card(
                  elevation: 8.0, // Increased elevation for a more premium feel
                  color: colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)), // More rounded corners
                  clipBehavior: Clip.antiAlias, // Ensures content respects rounded corners
                  child: InkWell( // Make the whole card tappable for "unlock" action
                    onTap: () {
                      // TODO: Implement NFC tap/unlock functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Room key tapped! (NFC action pending)')),
                      );
                    },
                    borderRadius: BorderRadius.circular(24.0), // Match card border radius
                    child: Padding(
                      padding: const EdgeInsets.all(28.0), // Increased padding for spaciousness
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hotel Name/Logo (Placeholder)
                          Text(
                            _hotelName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24.0), // More vertical space

                          // Room Number - Made more prominent
                          Text(
                            'ROOM',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                              letterSpacing: 2.0, // Increased letter spacing
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _roomNumber,
                            style: theme.textTheme.displayLarge?.copyWith( // Larger font size
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w900, // Extra bold
                            ),
                          ),
                          const SizedBox(height: 32.0), // More vertical space

                          // Guest & Dates Section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start, // Align top of children
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GUEST',
                                      style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onPrimaryContainer.withOpacity(0.7), letterSpacing: 1.0),
                                    ),
                                    Text(
                                      _guestName,
                                      style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0), // Space between guest and dates
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CHECK-IN',
                                    style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onPrimaryContainer.withOpacity(0.7), letterSpacing: 1.0),
                                  ),
                                  Text(
                                    _checkInDate, // Using dynamic date
                                    style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onPrimaryContainer),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'CHECK-OUT',
                                    style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onPrimaryContainer.withOpacity(0.7), letterSpacing: 1.0),
                                  ),
                                  Text(
                                    _checkOutDate, // Using dynamic date
                                    style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onPrimaryContainer),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 32.0), // More space before NFC area

                          // NFC Interaction Area
                          Center(
                            child: Column(
                              children: [
                                Image.network(
                                  _nfcGifUrl,
                                  fit: BoxFit.contain,
                                  height: 120, // Increased GIF size
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(height: 120, child: Center(child: CircularProgressIndicator(color: colorScheme.onPrimaryContainer.withOpacity(0.5))));
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.nfc_rounded, size: 100, color: colorScheme.onPrimaryContainer.withOpacity(0.5));
                                  },
                                ),
                                const SizedBox(height: 16.0), // Space between GIF and text
                                Text(
                                  'Tap phone on door handle to unlock',
                                  style: theme.textTheme.titleLarge?.copyWith( // Larger, more prominent text
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0), // Space before NFC info box

                // NFC Information Box - Styled for clarity
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer, // A distinct background color
                    borderRadius: BorderRadius.circular(16.0), // Match key card's roundedness
                    border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5), width: 1.0), // Subtle border
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline_rounded, color: colorScheme.onSurfaceVariant, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'NFC must be enabled on your device to use this feature. Ensure your phone is unlocked.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4, // Improve line spacing
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0), // Final padding at bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
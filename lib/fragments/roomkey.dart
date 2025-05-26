import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class RoomKeyPage extends StatefulWidget { // Changed to StatefulWidget
  const RoomKeyPage({super.key});

  @override
  State<RoomKeyPage> createState() => _RoomKeyPageState();
}

class _RoomKeyPageState extends State<RoomKeyPage> { // New State class
  // Define a max width for desktop-like content presentation
  static const double _contentMaxWidth = 400.0; // Adjusted for a card-like appearance
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
    final dateFormat = DateFormat('MMM d, yyyy'); // Example: May 26, 2025

    _checkInDate = dateFormat.format(now);
    _checkOutDate = dateFormat.format(now.add(const Duration(days: 2))); // Check-out 2 days from now

    // No need to call setState here as initState is called before the first build
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
                // Header Section
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
                        'Room Key', // Changed title slightly
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
                  elevation: 4.0, // Give it a slight lift
                  color: colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), // More rounded
                  clipBehavior: Clip.antiAlias,
                  child: InkWell( // Make the whole card tappable for "unlock" action
                    onTap: () {
                      // TODO: Implement NFC tap/unlock functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Room key tapped! (NFC action pending)')),
                      );
                    },
                    borderRadius: BorderRadius.circular(20.0),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hotel Name/Logo (Placeholder)
                          Text(
                            _hotelName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'ROOM',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            _roomNumber,
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'GUEST',
                                    style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onPrimaryContainer.withOpacity(0.7)),
                                  ),
                                  Text(
                                    _guestName,
                                    style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              // You can add another piece of info here if needed
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CHECK-IN',
                                    style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onPrimaryContainer.withOpacity(0.7)),
                                  ),
                                  Text(
                                    _checkInDate, // Using dynamic date
                                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimaryContainer),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'CHECK-OUT',
                                    style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onPrimaryContainer.withOpacity(0.7)),
                                  ),
                                  Text(
                                    _checkOutDate, // Using dynamic date
                                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimaryContainer),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24.0),
                          Center( // Center the NFC interaction area
                            child: Column(
                              children: [
                                Image.network(
                                  _nfcGifUrl,
                                  fit: BoxFit.contain,
                                  height: 100, // Adjusted GIF size
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.nfc_rounded, size: 80, color: colorScheme.onPrimaryContainer.withOpacity(0.5));
                                  },
                                ),
                                const SizedBox(height: 12.0),
                                Text(
                                  'Tap phone on door handle to unlock',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
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
                const SizedBox(height: 20.0),

                // NFC Information
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest, // A slightly different background for this info
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'NFC must be enabled on your device to use this feature.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
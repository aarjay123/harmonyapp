import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class RoomKeyPage extends StatefulWidget {
  const RoomKeyPage({super.key});

  @override
  State<RoomKeyPage> createState() => _RoomKeyPageState();
}

class _RoomKeyPageState extends State<RoomKeyPage> {
  // Define a max width for desktop-like content presentation
  static const double _contentMaxWidth = 450.0;
  final String _nfcGifUrl = 'https://cdn.dribbble.com/users/1489841/screenshots/11131159/nfc.gif';

  // Placeholder data
  final String _hotelName = "weB&B by The Highland Cafe™️";
  final String _roomNumber = "305";
  final String _guestName = "John Smith";

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
    final dateFormat = DateFormat('EEE, MMM d, y');

    _checkInDate = dateFormat.format(now);
    _checkOutDate = dateFormat.format(now.add(const Duration(days: 2)));
  }

  /// **NEW**: Builds the main page header consistent with the HiCard app style.
  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      // UPDATED: Removed horizontal padding to prevent double-padding from the parent widget.
      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: [colorScheme.primary, colorScheme.tertiary],
            ).createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            child: Text(
              'Room Key',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'Your digital key and stay details.',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // **UPDATED**: Using the new HiCard-style header.
                    _buildHeader(context),

                    // Digital Key Card
                    Card(
                      elevation: 8.0,
                      color: colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Your room is unlocked successfully.')),
                          );
                        },
                        borderRadius: BorderRadius.circular(24.0),
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _hotelName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 24.0),
                              Text(
                                'ROOM',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _roomNumber,
                                style: theme.textTheme.displayLarge?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 32.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                              const SizedBox(height: 16.0),
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
                                        _checkInDate,
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
                                        _checkOutDate,
                                        style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onPrimaryContainer),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32.0),
                              Center(
                                child: Column(
                                  children: [
                                    Image.network(
                                      _nfcGifUrl,
                                      fit: BoxFit.contain,
                                      height: 120,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return SizedBox(height: 120, child: Center(child: CircularProgressIndicator(color: colorScheme.onPrimaryContainer.withOpacity(0.5))));
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.nfc_rounded, size: 100, color: colorScheme.onPrimaryContainer.withOpacity(0.5));
                                      },
                                    ),
                                    const SizedBox(height: 16.0),
                                    Text(
                                      'Tap phone on door handle to unlock',
                                      style: theme.textTheme.titleLarge?.copyWith(
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
                    const SizedBox(height: 24.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5), width: 1.0),
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
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

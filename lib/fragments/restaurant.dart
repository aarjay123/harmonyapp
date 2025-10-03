import 'package:flutter/material.dart';
import 'dart:math'; // NEW: Required for generating random numbers.

// Import the restaurant-specific sub-pages
import 'restaurant/hicafe_page.dart';
import 'restaurant/breakfast_page.dart';
import 'restaurant/cafefiesta_page.dart';
import 'restaurant/locations_page.dart';

// NEW: Import the settings UI components and the new ad dialog.
import '../settings_ui_components.dart';
import '../widgets/video_ad_dialog.dart'; // Make sure this path is correct

class RestaurantPage extends StatelessWidget {
  const RestaurantPage({super.key});

  static const double _contentMaxWidth = 1200.0;

  // NEW: This helper method decides whether to show an ad.
  void _showAdIfNeeded(BuildContext context, VoidCallback onProceed) {
    final random = Random();
    // This gives a 1 in 4 (25%) chance of showing an ad. You can adjust this value.
    if (random.nextInt(4) == 0) {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing by tapping outside the dialog
        builder: (_) => VideoAdDialog(onSkipped: onProceed),
      );
    } else {
      // If no ad is shown, execute the original action immediately.
      onProceed();
    }
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
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
              'Food',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'Pick an action from below.',
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
    final colorScheme = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> restaurantActions = [
      {
        'icon': Icons.local_cafe_rounded,
        'label': 'Your HiCafe™ Visit',
        'page': const HiCafePage(),
      },
      {
        'icon': Icons.egg_alt_rounded,
        'label': 'Breakfast Check-In',
        'page': const BreakfastCheckInPage(),
      },
      {
        'icon': Icons.coffee_maker_rounded,
        'label': 'CafeFiesta™️',
        'page': const CafeFiestaPage(),
      },
      {
        'icon': Icons.pin_drop_rounded,
        'label': 'Locations',
        'page': const RestaurantLocationsPage(),
      },
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildHeader(context),
                const SizedBox(height: 8.0),
                ...List.generate(restaurantActions.length, (index) {
                  final action = restaurantActions[index];
                  // This is the original action (navigating to a new page).
                  final VoidCallback proceedAction = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => action['page'] as Widget),
                    );
                  };

                  return SettingsListItem(
                    icon: action['icon'] as IconData,
                    label: action['label'] as String,
                    // UPDATED: The onTap now calls our ad helper method.
                    onTap: () => _showAdIfNeeded(context, proceedAction),
                    isFirstItem: index == 0,
                    isLastItem: index == restaurantActions.length - 1,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
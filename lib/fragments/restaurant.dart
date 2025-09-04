import 'package:flutter/material.dart';

// Import the restaurant-specific sub-pages
import 'restaurant/hicafe_page.dart';
import 'restaurant/breakfast_page.dart';
import 'restaurant/cafefiesta_page.dart';
import 'restaurant/locations_page.dart';

// NEW: Import the settings UI components to use for the buttons.
// Please ensure this path is correct for your project structure.
import '../settings_ui_components.dart';

class RestaurantPage extends StatelessWidget {
  const RestaurantPage({super.key});

  static const double _contentMaxWidth = 1200.0;

  /// Builds the header consistent with the other pages.
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

  // REMOVED: The custom _buildRestaurantOption widget is no longer needed.
  // The logic is now handled by the reusable SettingsListItem component.

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
                // UPDATED: The list now uses the SettingsListItem component
                // to create the buttons for a consistent UI.
                ...List.generate(restaurantActions.length, (index) {
                  final action = restaurantActions[index];
                  return SettingsListItem(
                    icon: action['icon'] as IconData,
                    label: action['label'] as String,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => action['page'] as Widget),
                      );
                    },
                    // These flags ensure the corners are rounded correctly for the list.
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

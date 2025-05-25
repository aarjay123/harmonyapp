import 'package:flutter/material.dart';

// Import the newly created HiCafePage
// Assuming hicafe_page.dart is in a subdirectory 'restaurant' under 'fragments'
// Adjust the path if your file structure is different.
import 'restaurant/hicafe_page.dart';
import 'restaurant/breakfast_page.dart';
import 'restaurant/cafefiesta_page.dart';
import 'restaurant/locations_page.dart';

class RestaurantPage extends StatelessWidget {
  const RestaurantPage({super.key});

  // Helper function to create styled list items similar to the buttons
  Widget _buildRestaurantOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define border radius based on position
    BorderRadius borderRadius;
    if (isFirst && isLast) { // Only one item
      borderRadius = BorderRadius.circular(16.0);
    } else if (isFirst) {
      borderRadius = const BorderRadius.vertical(top: Radius.circular(16.0), bottom: Radius.circular(5.0));
    } else if (isLast) {
      borderRadius = const BorderRadius.vertical(top: Radius.circular(5.0), bottom: Radius.circular(16.0));
    } else {
      borderRadius = BorderRadius.circular(5.0);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 1.0), // Small gap like settings items
      child: Material(
        color: colorScheme.secondaryContainer, // Using a card-like color
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            child: Row(
              children: [
                Icon(icon, color: colorScheme.onSecondaryContainer, size: 28), // Adjusted for secondaryContainer
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer, // Adjusted for secondaryContainer
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7)), // Adjusted for secondaryContainer
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Gradient for the main title (similar to welcome page) - REMOVED as per request
    // final Shader titleGradientShader = LinearGradient(
    //   colors: <Color>[colorScheme.primary, colorScheme.tertiary], // You can adjust these colors
    //   begin: Alignment.topLeft,
    //   end: Alignment.bottomRight,
    // ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)); // Adjust rect size as needed


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
      backgroundColor: colorScheme.surface, // Consistent background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section - styled like welcome page
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // Align icon and text vertically
                    children: [
                      Icon(
                        Icons.restaurant_rounded,
                        size: 36, // Slightly larger icon for displaySmall
                        color: colorScheme.primary, // Icon color set to primary
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Food', // Main title
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary, // Title color set to primary
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Subtitle alignment changed, and text style changed
                  Text(
                    'Pick an action from below.', // Subtitle
                    style: theme.textTheme.bodyMedium?.copyWith( // Made subtitle smaller
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 20.0), // Original spacing before action items, adjust as needed

            // Action Items
            Container(
              // Removed card background from here, items are now styled individually
              child: Column(
                children: List.generate(restaurantActions.length, (index) {
                  final action = restaurantActions[index];
                  return _buildRestaurantOption(
                    context: context,
                    icon: action['icon'] as IconData,
                    label: action['label'] as String,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => action['page'] as Widget),
                      );
                    },
                    isFirst: index == 0,
                    isLast: index == restaurantActions.length - 1,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
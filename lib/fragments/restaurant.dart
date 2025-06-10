// fragments/restaurant.dart

import 'package:flutter/material.dart';

// Import the newly created HiCafePage
import 'restaurant/hicafe_page.dart';
import 'restaurant/breakfast_page.dart';
import 'restaurant/cafefiesta_page.dart';
import 'restaurant/locations_page.dart';

class RestaurantPage extends StatelessWidget {
  const RestaurantPage({super.key});

  // Define a max width for desktop-like content presentation
  static const double _contentMaxWidth = 768.0;

  // Helper function to create styled list items for restaurant options
  Widget _buildRestaurantOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Apply a consistent border radius to all cards
    BorderRadius borderRadius = BorderRadius.circular(16.0);

    return Container(
      // No external margin here, spacing is handled by SizedBox in the parent Column
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer, // Background color for the item
        borderRadius: borderRadius,
        boxShadow: [ // Softer shadow for depth
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Slightly more visible than 0.05, but still subtle
            spreadRadius: 1,
            blurRadius: 6, // Slightly more blur
            offset: const Offset(0, 3), // More pronounced vertical offset
          ),
        ],
      ),
      child: Material( // Material widget for InkWell splash effect
        color: Colors.transparent, // Make Material transparent to show Container's decoration
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius, // Match container's border radius
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0), // Generous internal padding
            child: Row(
              children: [
                Icon(icon, color: colorScheme.onSecondaryContainer, size: 32), // Clear icon size
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleLarge?.copyWith( // Prominent and bold text
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7)), // Navigation icon
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
        padding: const EdgeInsets.symmetric(vertical: 16.0), // Apply vertical padding to scroll view
        child: Center( // Center the constrained content
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
            child: Padding( // Apply horizontal padding after constraining width
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section - styled like welcome page (Kept as requested)
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
                  const SizedBox(height: 12.0), // Adjusted spacing before list items

                  // Action Items - Now a refined list
                  Column(
                    children: List.generate(restaurantActions.length, (index) {
                      final action = restaurantActions[index];
                      // Add SizedBox for vertical spacing BETWEEN items
                      return Padding(
                        padding: EdgeInsets.only(bottom: index == restaurantActions.length - 1 ? 0.0 : 12.0), // Space after each, but not the last
                        child: _buildRestaurantOption(
                          context: context,
                          icon: action['icon'] as IconData,
                          label: action['label'] as String,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => action['page'] as Widget),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
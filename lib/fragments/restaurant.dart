import 'package:flutter/material.dart';

// Import the restaurant-specific sub-pages
// Ensure these files exist in your project structure.
import 'restaurant/hicafe_page.dart';
import 'restaurant/breakfast_page.dart';
import 'restaurant/cafefiesta_page.dart';
import 'restaurant/locations_page.dart';

class RestaurantPage extends StatelessWidget {
  const RestaurantPage({super.key});

  // UPDATED: Define a max width consistent with other pages for a unified look.
  static const double _contentMaxWidth = 1200.0;

  /// Builds the header consistent with the other pages.
  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      // UPDATED: Removed horizontal padding to prevent double-padding from the parent ListView, which fixes the alignment gap.
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

  // UPDATED: Helper function to create redesigned, modern list items.
  Widget _buildRestaurantOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(24.0);

    return Card(
      elevation: 0,
      // Using a slightly different color for better contrast against the background.
      color: colorScheme.surfaceVariant.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        // Adding a subtle border for definition.
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Row(
            children: [
              // Icon is now wrapped in a colored circle for emphasis.
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 24),
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16.0),
              Icon(Icons.arrow_forward_ios_rounded, color: colorScheme.onSurfaceVariant.withOpacity(0.6), size: 18),
            ],
          ),
        ),
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
        // UPDATED: The entire page is wrapped for consistent responsive behavior.
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildHeader(context),
                const SizedBox(height: 8.0), // Reduced space after header
                ...restaurantActions.map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
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
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

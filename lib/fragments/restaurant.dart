import 'package:flutter/material.dart';
import '../settings_ui_components.dart';
import 'restaurant/breakfast_page.dart';
import 'restaurant/cafefiesta_page.dart';
import 'restaurant/hicafe_page.dart';
import 'restaurant/locations_page.dart';

class RestaurantPage extends StatelessWidget {
  const RestaurantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kSettingsContentMaxWidth),
          child: CustomScrollView(
            slivers: [
              // Replaced SliverAppBar with SliverSafeArea to remove the title
              // and ensure content starts safely below the status bar.
              SliverSafeArea(
                bottom: false, // Let the content handle bottom padding
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    // Maintains the "small bit of margin" above content
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                    child: Column(
                      children: [
                        // --- Top Card (Header) ---
                        Card(
                          elevation: 0,
                          color: colorScheme.surfaceContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.restaurant_rounded,
                                      color: colorScheme.primary, 
                                      size: 32,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Food',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pick an action from below.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // --- Action List using SettingsListItem ---
                        SettingsListItem(
                          icon: Icons.local_cafe_rounded,
                          label: 'Your HiCafe™️ Visit',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HiCafePage())),
                          isFirstItem: true,
                        ),
                        SettingsListItem(
                          icon: Icons.egg_rounded,
                          label: 'Breakfast Check-In',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BreakfastCheckInPage())),
                        ),
                        SettingsListItem(
                          icon: Icons.coffee_maker_rounded,
                          label: 'CafeFiesta™️',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CafeFiestaPage())),
                        ),
                        SettingsListItem(
                          icon: Icons.pin_drop_rounded,
                          label: 'Locations',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RestaurantLocationsPage())),
                          isLastItem: true,
                        ),

                        const SizedBox(height: 80), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'restaurant/breakfast_page.dart';
import 'restaurant/cafefiesta_page.dart';
import 'restaurant/hicafe_page.dart';
import 'restaurant/locations_page.dart';

class RestaurantPage extends StatelessWidget {
  const RestaurantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text('Dining', style: TextStyle(color: colorScheme.onSurface)),
            backgroundColor: colorScheme.surface,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.withOpacity(0.3), colorScheme.surface],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.restaurant_menu_rounded, size: 80, color: Colors.red.withOpacity(0.5)),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _buildDiningCard(context, 'Breakfast', Icons.bakery_dining_rounded, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BreakfastCheckInPage()))),
                _buildDiningCard(context, 'Cafe Fiesta', Icons.local_pizza_rounded, Colors.red, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CafeFiestaPage()))),
                _buildDiningCard(context, 'HiCafe', Icons.coffee_rounded, Colors.brown, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HiCafePage()))),
                _buildDiningCard(context, 'Locations', Icons.map_rounded, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RestaurantLocationsPage()))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiningCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
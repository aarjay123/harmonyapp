import 'package:flutter/material.dart';

// Import help articles
import 'articles/internet_help_page.dart';
import 'articles/hotel_help_page.dart';
import 'articles/restaurant_help_page.dart';
import 'articles/roomkey_help_page.dart';
import 'articles/app_tutorial_page.dart';
import 'articles/customer_support_page.dart';
import 'articles/app_feedback_info_page.dart';
import 'articles/updates_help_page.dart';
import 'articles/terms_conditions_page.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<_HelpCategory> categories = [
      _HelpCategory(
        title: 'Internet',
        icon: Icons.wifi_rounded,
        color: Colors.blue,
        page: const InternetHelpPage(),
      ),
      _HelpCategory(
        title: 'Hotel Info',
        icon: Icons.hotel_rounded,
        color: Colors.orange,
        page: const HotelHelpPage(),
      ),
      _HelpCategory(
        title: 'Restaurant',
        icon: Icons.restaurant_rounded,
        color: Colors.red,
        page: const RestaurantHelpPage(),
      ),
      _HelpCategory(
        title: 'Room Key',
        icon: Icons.vpn_key_rounded,
        color: Colors.amber,
        page: const RoomKeyHelpPage(),
      ),
      _HelpCategory(
        title: 'App Tutorial',
        icon: Icons.school_rounded,
        color: Colors.purple,
        page: const AppTutorialPage(),
      ),
      _HelpCategory(
        title: 'Support',
        icon: Icons.support_agent_rounded,
        color: Colors.green,
        page: const CustomerSupportPage(),
      ),
      _HelpCategory(
        title: 'Updates',
        icon: Icons.system_update_rounded,
        color: Colors.cyan,
        page: const UpdatesHelpPage(),
      ),
      _HelpCategory(
        title: 'Feedback',
        icon: Icons.feedback_rounded,
        color: Colors.pink,
        page: const AppFeedbackInfoPage(),
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text('Help Center', style: TextStyle(color: colorScheme.onSurface)),
            backgroundColor: colorScheme.surface,
            pinned: true,
          ),

          // Welcome / Search Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How can we help you?',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Fake search bar for visual appeal
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 12),
                        Text(
                          'Search for help...',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Categories Grid
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columns
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5, // Wider cards
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final cat = categories[index];
                  return _buildCategoryCard(context, cat);
                },
                childCount: categories.length,
              ),
            ),
          ),

          // Terms & Legal Footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsPage())),
                icon: const Icon(Icons.gavel_rounded),
                label: const Text('Terms & Conditions'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, _HelpCategory category) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => category.page)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(category.icon, color: category.color),
              ),
              Text(
                category.title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpCategory {
  final String title;
  final IconData icon;
  final Color color;
  final Widget page;

  _HelpCategory({required this.title, required this.icon, required this.color, required this.page});
}
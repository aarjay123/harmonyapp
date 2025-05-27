import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings/settings_page.dart'; // Assuming this path is correct
import 'helpcenter/helpcenter_page.dart'; // Assuming this path is correct

class FullscreenMenuPage extends StatelessWidget {
  const FullscreenMenuPage({super.key});

  static const double _contentMaxWidth = 768.0; // Consistent max width

  // Helper function to build menu items, similar to _buildRestaurantOption
  Widget _buildMenuItemCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    BorderRadius borderRadius;
    if (isFirst && isLast) { // Only one item in a group
      borderRadius = BorderRadius.circular(16.0);
    } else if (isFirst) {
      borderRadius = const BorderRadius.vertical(top: Radius.circular(16.0), bottom: Radius.circular(5.0));
    } else if (isLast) {
      borderRadius = const BorderRadius.vertical(top: Radius.circular(5.0), bottom: Radius.circular(16.0));
    } else { // Middle items
      borderRadius = BorderRadius.circular(5.0);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 1.0), // Small gap between items
      child: Material(
        color: colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            child: Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: 26),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7)),
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

    final menuItems = [
      _MenuItem(
        icon: Icons.download_for_offline_rounded,
        label: 'Download Menus',
        url: 'https://www.dropbox.com/scl/fo/7gmlnnjcau1np91ee83ht/h?rlkey=ifj506k3aal7ko7tfecy8oqyq&dl=0',
      ),
      _MenuItem(
        icon: Icons.settings_rounded,
        label: 'Settings',
        page: const SettingsPage(),
      ),
      _MenuItem(
        icon: Icons.help_outline_rounded,
        label: 'Help',
        page: const HelpcenterPage(),
      ),
      _MenuItem(
        icon: Icons.web_rounded,
        label: 'Visit Blog',
        url: 'https://hienterprises.blogspot.com',
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface, // Use surface for main background
      appBar: AppBar(
        title: const Text('Menu'), // AppBar title
        backgroundColor: colorScheme.surface, // Match page background for a flatter look
        elevation: 0, // Flat AppBar
        foregroundColor: colorScheme.onSurface, // Ensure icons/text are visible
        // Back button is automatically added by Navigator when this page is pushed
      ),
      body: SafeArea( // Keep SafeArea if you want to ensure content below AppBar is not obscured
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Removed the custom IconButton back button
                    // const SizedBox(height: 16.0), // Adjust spacing if needed after removing custom back button

                    // Header Section - Styled like HotelPage
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_rounded, // Example icon for Menu
                          size: 36,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Menu', // This title is now somewhat redundant with AppBar, consider removing or changing
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text( // Optional subtitle for the menu page
                      'Explore app features and settings.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24), // Spacing before menu items

                    // Grouped Menu Items
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch cards
                      children: List.generate(menuItems.length, (index) {
                        final item = menuItems[index];
                        return _buildMenuItemCard(
                          context: context,
                          icon: item.icon,
                          label: item.label,
                          onTap: () async {
                            if (item.page != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => item.page!),
                              );
                            } else if (item.url != null) {
                              final uri = Uri.parse(item.url!);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Could not launch ${item.url}')),
                                  );
                                }
                              }
                            }
                          },
                          isFirst: index == 0,
                          isLast: index == menuItems.length - 1,
                        );
                      }),
                    ),
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

// Data class for menu items (remains the same)
class _MenuItem {
  final IconData icon;
  final String label;
  final Widget? page;
  final String? url;

  _MenuItem({
    required this.icon,
    required this.label,
    this.page,
    this.url,
  });
}
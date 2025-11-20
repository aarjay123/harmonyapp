// lib/widgets/responsive_scaffold.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Import models, pages, and other widgets
import '../models/app_destination.dart';
import '../theme_provider.dart'; // Assumed path

// Import your fragments (pages)
import '../fragments/home.dart';
import '../fragments/restaurant.dart';
import '../fragments/rewards_page.dart';
import '../fragments/hotel.dart';
import '../fragments/roomkey.dart';

import '../settings/settings_page.dart';
import '../helpcenter/helpcenter_page.dart';

// Import the custom AnimatedFabMenu widget
import 'animated_fab_menu.dart'; // Make sure this path is correct

// ResponsiveScaffold is the main UI scaffold that adapts navigation for wide or narrow screens
class ResponsiveScaffold extends StatefulWidget {
  final bool dynamicColorSupported; // Whether dynamic color is supported on this device

  const ResponsiveScaffold({Key? key, required this.dynamicColorSupported})
      : super(key: key);

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _selectedIndex = 0; // Tracks currently selected navigation index

  // The master list of destinations, now including both icon variants.
  late final List<AppDestination> _allDestinations;

  @override
  void initState() {
    super.initState();
    // Initialize the master list here with your updated destinations.
    _allDestinations = [
      AppDestination(id: 'dashboard', label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home, page: NativeWelcomePage(onNavigateToTab: _onItemTapped)),
      AppDestination(id: 'food', label: 'Food', icon: Icons.restaurant_outlined, selectedIcon: Icons.restaurant, page: const RestaurantPage()),
      AppDestination(id: 'rewards', label: 'Rewards', icon: Icons.stars, selectedIcon: Icons.stars, page: const RewardsPage()),
      AppDestination(id: 'hotel', label: 'Hotel', icon: Icons.hotel_outlined, selectedIcon: Icons.hotel, page: const HotelPage()),
      AppDestination(id: 'room_key', label: 'Room Key', icon: Icons.key_outlined, selectedIcon: Icons.key, page: const RoomkeyFragment()),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // This function now guarantees the dashboard is always included.
  List<AppDestination> _getVisibleDestinations(ThemeProvider themeProvider) {
    // Start with the dashboard, which is always visible.
    final List<AppDestination> visible = [_allDestinations.first];

    // Filter the rest of the destinations based on user settings.
    final otherVisible = _allDestinations.skip(1).where((dest) {
      return themeProvider.visibleDestinations[dest.id] ?? true;
    });

    visible.addAll(otherVisible);
    return visible;
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 600;
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Dynamically build the list of destinations that should be visible.
    final List<AppDestination> visibleDestinations = _getVisibleDestinations(themeProvider);

    // If the currently selected index is out of bounds (because an item was hidden),
    // reset to the first page.
    if (_selectedIndex >= visibleDestinations.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      });
    }

    // Define the MiniFabItems with the updated outlined icons.
    final List<MiniFabItem> menuFabItems = [
      MiniFabItem(
        icon: Icons.download_for_offline_outlined,
        label: 'Download Menus',
        onTap: () => _launchExternalUrl('https://www.dropbox.com/scl/fo/7gmlnnjcau1np91ee83ht/h?rlkey=ifj506k3aal7ko7tfecy8oqyq&dl=0'),
      ),
      MiniFabItem(
        icon: Icons.settings_outlined,
        label: 'Settings',
        onTap: () => _navigateToPage(const SettingsPage()),
      ),
      MiniFabItem(
        icon: Icons.help_outline_rounded,
        label: 'Help',
        onTap: () => _navigateToPage(const HelpCenterPage()),
      ),
      MiniFabItem(
        icon: Icons.web_outlined,
        label: 'Visit Blog',
        onTap: () => _launchExternalUrl('https://hienterprises.blogspot.com'),
      ),
    ];

    return Scaffold(
      body: Row(
        children: [
          if (isWideScreen) _buildNavigationRail(isWideScreen, visibleDestinations),
          Expanded(
            child: visibleDestinations.isEmpty
                ? const Center(child: Text("An error has occurred."))
                : visibleDestinations[_selectedIndex].page,
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen ? null : _buildNavigationBar(themeProvider.useMaterial3, visibleDestinations),
      floatingActionButton: AnimatedFabMenu(fabItems: menuFabItems),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Helper for launching URLs
  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  // Helper for navigation
  void _navigateToPage(Widget page) {
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  // UPDATED: Now uses the `selectedIcon` property for a cleaner implementation.
  NavigationRail _buildNavigationRail(bool isWideScreen, List<AppDestination> destinations) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelType: isWideScreen
          ? NavigationRailLabelType.all
          : NavigationRailLabelType.none,
      destinations: destinations.map((dest) {
        return NavigationRailDestination(
          icon: Icon(dest.icon),
          selectedIcon: Icon(dest.selectedIcon), // Use the filled icon for the selected state
          label: Text(dest.label),
        );
      }).toList(),
    );
  }

  // UPDATED: Now uses the `selectedIcon` property for M3 and dynamic icons for M2.
  Widget _buildNavigationBar(bool useMaterial3, List<AppDestination> destinations) {
    if (useMaterial3) {
      return NavigationBar(
        height: 55,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: destinations.map((dest) {
          return NavigationDestination(
            icon: Icon(dest.icon),
            selectedIcon: Icon(dest.selectedIcon), // Use the filled icon for the selected state
            label: dest.label,
          );
        }).toList(),
      );
    } else {
      // Material 2 style BottomNavigationBar
      return BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        // Dynamically build the items, choosing the correct icon based on the selected index.
        items: destinations.asMap().entries.map((entry) {
          final int index = entry.key;
          final AppDestination dest = entry.value;
          return BottomNavigationBarItem(
            icon: Icon(_selectedIndex == index ? dest.selectedIcon : dest.icon),
            label: dest.label,
          );
        }).toList(),
      );
    }
  }
}
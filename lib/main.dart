// Import Flutter core libraries
import 'package:flutter/foundation.dart' show kIsWeb; // For platform detection if needed
import 'package:flutter/material.dart';

// Import third-party packages
import 'package:provider/provider.dart'; // State management
import 'package:dynamic_color/dynamic_color.dart'; // For Material You dynamic colors (Android 12+)
// InAppWebView might still be used by other sub-pages, but FullscreenMenuPage is replaced
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart'; // NEW: For canLaunchUrl, launchUrl, LaunchMode

// Import your own app files for theming, helpers, and UI components
import 'theme_provider.dart'; // Custom ThemeProvider managing theme state and preferences
import 'colour_scheme.dart'; // Defines your app's color schemes
import 'device_info_helper.dart'; // Helper for checking device capabilities like dynamic color support
import 'global_slide_transition_builder.dart'; // Custom page transitions (e.g., GlobalSlidePageTransitionsBuilder)

// Import your fragments (pages)
import 'fragments/home.dart';
import 'fragments/restaurant.dart';
import 'fragments/rewards_page.dart';
import 'fragments/hotel.dart';
import 'fragments/roomkey.dart';

import 'settings/settings_page.dart';
import 'helpcenter/helpcenter_page.dart';

// NEW: Import the custom AnimatedFabMenu widget
import 'widgets/animated_fab_menu.dart'; // Make sure this path is correct

// The main entry point of the Flutter app
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter engine is initialized before running app
  runApp(const AppLoader()); // Runs the root widget AppLoader
}

// Stateful widget to handle async initialization before showing main app
class AppLoader extends StatefulWidget {
  const AppLoader({Key? key}) : super(key: key);

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  ThemeProvider? _themeProvider; // Holds the theme provider instance once loaded
  bool _error = false; // Flag to indicate if initialization failed
  bool _dynamicColorSupported = false; // Flag for whether dynamic color is supported on device

  @override
  void initState() {
    super.initState();
    _initTheme(); // Start theme initialization asynchronously on widget load
  }

  // Async method to initialize theme provider and detect dynamic color support
  Future<void> _initTheme() async {
    try {
      // Check device capability for dynamic color (Android 12+)
      final supported = await DeviceInfoHelper.supportsDynamicColor();
      _dynamicColorSupported = supported;

      // Create theme provider with dynamic color enabled flag
      final themeProvider = ThemeProvider(dynamicColorEnabled: supported);
      await themeProvider.loadPreferences(); // Load saved user theme preferences

      // If device doesn't support dynamic color, forcibly disable it in provider
      if (!supported) {
        themeProvider.dynamicColorEnabled = false;
      }

      // Update state with loaded provider instance, triggers UI rebuild
      setState(() {
        _themeProvider = themeProvider;
      });
    } catch (e, st) {
      // On error, log and set error flag to show error UI
      debugPrint('Failed to init theme: $e\n$st');
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If error occurred or theme provider is still null (loading), show error message
    if (_error || _themeProvider == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Failed to load preferences')),
        ),
      );
    }

    // Provide the loaded ThemeProvider to the widget subtree via Provider package
    return ChangeNotifierProvider.value(
      value: _themeProvider!,
      child: MyApp(dynamicColorSupported: _dynamicColorSupported),
    );
  }
}

// Main app widget, builds MaterialApp with theming based on dynamic color support and user preference
class MyApp extends StatelessWidget {
  final bool dynamicColorSupported; // Passed from AppLoader, device capability flag

  const MyApp({Key? key, required this.dynamicColorSupported}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      // Builder provides dynamic light and dark color schemes if available
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final themeProvider = Provider.of<ThemeProvider>(context);

        // Determine if dynamic color should be used based on device and user settings
        final useDynamic =
            themeProvider.dynamicColorEnabled && dynamicColorSupported;

        // Common CardThemeData definition based on Material 3 toggle
        final CardThemeData commonCardTheme = CardThemeData( // Changed from CardTheme to CardThemeData
          // Sharper corners for Material 2, softer for Material 3
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(themeProvider.useMaterial3 ? 12.0 : 8.0),
          ),
          // More pronounced shadow for Material 2, subtle for Material 3
          elevation: themeProvider.useMaterial3 ? 1.0 : 4.0,
        );


        if (useDynamic) {
          // If dynamic colors enabled and supported, build MaterialApp using them
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Harmony',
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: themeProvider.useMaterial3, // Enable Material 3 design
              colorScheme: lightDynamic ?? lightColorScheme, // Use dynamic or fallback light scheme
              textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Outfit'), // Custom font
              cardTheme: commonCardTheme, // Apply the common card theme
              // FIXED: Removed 'const' because the for-loop makes it a non-constant expression.
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  // Apply custom slide transition on all platforms
                  for (final platform in TargetPlatform.values)
                    platform: GlobalSlidePageTransitionsBuilder(),
                },
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: themeProvider.useMaterial3,
              colorScheme: darkDynamic ?? darkColorScheme, // Use dynamic or fallback dark scheme
              textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Outfit'),
              cardTheme: commonCardTheme, // Apply the common card theme
              // FIXED: Removed 'const' because the for-loop makes it a non-constant expression.
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  for (final platform in TargetPlatform.values)
                    platform: GlobalSlidePageTransitionsBuilder(),
                },
              ),
            ),
            // Main app content scaffold
            home: ResponsiveScaffold(dynamicColorSupported: dynamicColorSupported),
          );
        }

        // Otherwise, build app with user's selected color scheme (no dynamic color)
        final ColorScheme lightScheme = themeProvider.currentColorScheme;
        final ColorScheme darkScheme = ColorScheme.fromSeed(
          seedColor: lightScheme.primary,
          brightness: Brightness.dark,
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Harmony',
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            useMaterial3: themeProvider.useMaterial3,
            colorScheme: lightScheme,
            textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Outfit'),
            cardTheme: commonCardTheme, // Apply the common card theme
            // FIXED: Removed 'const' because the for-loop makes it a non-constant expression.
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                for (final platform in TargetPlatform.values)
                  platform: GlobalSlidePageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: themeProvider.useMaterial3,
            colorScheme: darkScheme,
            textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Outfit'),
            cardTheme: commonCardTheme, // Apply the common card theme
            // FIXED: Removed 'const' because the for-loop makes it a non-constant expression.
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                for (final platform in TargetPlatform.values)
                  platform: GlobalSlidePageTransitionsBuilder(),
              },
            ),
          ),
          home: ResponsiveScaffold(dynamicColorSupported: dynamicColorSupported),
        );
      },
    );
  }
}

// NEW: A model to represent a navigation destination.
class _AppDestination {
  final String id;
  final String label;
  final IconData icon;
  final Widget page;

  const _AppDestination({
    required this.id,
    required this.label,
    required this.icon,
    required this.page,
  });
}


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

  // NEW: A master list of all possible destinations.
  late final List<_AppDestination> _allDestinations;

  @override
  void initState() {
    super.initState();
    // Initialize the master list here.
    _allDestinations = [
      _AppDestination(id: 'dashboard', label: 'Dashboard', icon: Icons.dashboard_rounded, page: NativeWelcomePage(onNavigateToTab: _onItemTapped)),
      _AppDestination(id: 'food', label: 'Food', icon: Icons.restaurant_rounded, page: const RestaurantPage()),
      _AppDestination(id: 'rewards', label: 'Rewards', icon: Icons.stars_rounded, page: const RewardsPage()),
      _AppDestination(id: 'hotel', label: 'Hotel', icon: Icons.hotel_rounded, page: const HotelPage()),
      _AppDestination(id: 'room_key', label: 'Room Key', icon: Icons.key_rounded, page: const RoomKeyPage()),
    ];
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // UPDATED: This function now guarantees the dashboard is always included.
  List<_AppDestination> _getVisibleDestinations(ThemeProvider themeProvider) {
    // Start with the dashboard, which is always visible.
    final List<_AppDestination> visible = [_allDestinations.first];

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
    final themeProvider = Provider.of<ThemeProvider>(context); // Get themeProvider here

    // NEW: Dynamically build the list of destinations that should be visible.
    final List<_AppDestination> visibleDestinations = _getVisibleDestinations(themeProvider);

    // If the currently selected index is out of bounds (because an item was hidden),
    // reset to the first page.
    if (_selectedIndex >= visibleDestinations.length) {
      // Use a post-frame callback to avoid calling setState during a build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    }


    // Define the MiniFabItems based on the original FullscreenMenuPage items
    final List<MiniFabItem> menuFabItems = [
      MiniFabItem(
        icon: Icons.download_for_offline_rounded,
        label: 'Download Menus',
        onTap: () async {
          const url = 'https://www.dropbox.com/scl/fo/7gmlnnjcau1np91ee83ht/h?rlkey=ifj506k3aal7ko7tfecy8oqyq&dl=0';
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch $url')),
              );
            }
          }
        },
      ),
      MiniFabItem(
        icon: Icons.settings_rounded,
        label: 'Settings',
        onTap: () {
          if (context.mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
          }
        },
      ),
      MiniFabItem(
        icon: Icons.help_outline_rounded,
        label: 'Help',
        onTap: () {
          if (context.mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpcenterPage()));
          }
        },
      ),
      MiniFabItem(
        icon: Icons.web_rounded,
        label: 'Visit Blog',
        onTap: () async {
          const url = 'https://hienterprises.blogspot.com';
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch $url')),
              );
            }
          }
        },
      ),
    ];


    return Scaffold(
      // MODIFIED: Removed AppBar entirely
      body: Row(
        children: [
          if (isWideScreen) _buildNavigationRail(isWideScreen, visibleDestinations),
          Expanded(
            // Show the selected page from the visible list.
            child: visibleDestinations.isEmpty
                ? const Center(child: Text("An error has occurred.")) // Should not happen with dashboard always visible
                : visibleDestinations[_selectedIndex].page,
          ),
        ],
      ),
      // MODIFIED: Conditionally render NavigationBar or BottomNavigationBar
      bottomNavigationBar: isWideScreen ? null : _buildNavigationBar(themeProvider.useMaterial3, visibleDestinations),
      // NEW: Floating Action Button that expands into mini-FABs for menu items
      floatingActionButton: AnimatedFabMenu(fabItems: menuFabItems),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Position at bottom right
    );
  }

  // UPDATED: Now takes a list of destinations to build dynamically.
  NavigationRail _buildNavigationRail(bool isWideScreen, List<_AppDestination> destinations) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelType: isWideScreen
          ? NavigationRailLabelType.all
          : NavigationRailLabelType.none,
      destinations: destinations.map((dest) {
        return NavigationRailDestination(icon: Icon(dest.icon), label: Text(dest.label));
      }).toList(),
    );
  }

  // UPDATED: Now takes a list of destinations to build dynamically.
  Widget _buildNavigationBar(bool useMaterial3, List<_AppDestination> destinations) {
    if (useMaterial3) {
      return NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: destinations.map((dest) {
          return NavigationDestination(icon: Icon(dest.icon), label: dest.label);
        }).toList(),
      );
    } else {
      // Material 2 style BottomNavigationBar
      return BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures all items are visible and evenly spaced
        items: destinations.map((dest) {
          return BottomNavigationBarItem(icon: Icon(dest.icon), label: dest.label);
        }).toList(),
      );
    }
  }
}


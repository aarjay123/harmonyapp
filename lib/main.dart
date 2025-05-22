// Import Flutter core libraries
import 'package:flutter/foundation.dart' show kIsWeb; // For platform detection if needed
import 'package:flutter/material.dart';

// Import third-party packages
import 'package:provider/provider.dart'; // State management
import 'package:dynamic_color/dynamic_color.dart'; // For Material You dynamic colors (Android 12+)
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // For embedding web content

// Import your own app files for theming, helpers, and UI components
import 'theme_provider.dart'; // Custom ThemeProvider managing theme state and preferences
import 'colour_scheme.dart'; // Defines your app's color schemes
import 'device_info_helper.dart'; // Helper for checking device capabilities like dynamic color support
import 'fullscreen_menu_page.dart'; // Fullscreen menu page for app navigation
import 'global_slide_transition_builder.dart'; // Custom page transitions

// For platform-specific imports (e.g. non-web platforms)
import 'dart:io' show Platform;

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

        if (useDynamic) {
          // If dynamic colors enabled and supported, build MaterialApp using them
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Harmony',
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: true, // Enable Material 3 design
              colorScheme: lightDynamic ?? lightColorScheme, // Use dynamic or fallback light scheme
              textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Outfit'), // Custom font
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  // Apply custom slide transition on all platforms
                  for (final platform in TargetPlatform.values)
                    platform: GlobalSlidePageTransitionsBuilder(),
                },
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkDynamic ?? darkColorScheme, // Use dynamic or fallback dark scheme
              textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Outfit'),
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
            useMaterial3: true,
            colorScheme: lightScheme,
            textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Outfit'),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                for (final platform in TargetPlatform.values)
                  platform: GlobalSlidePageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
            textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Outfit'),
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
  InAppWebViewController? _webViewController; // Controller for controlling the embedded webview
  bool _isLoading = true; // Tracks loading state of the web content

  // List of URLs to load in the webview for each tab
  final List<String> _urls = [
    'https://thehighlandcafe.github.io/hioswebcore/welcome.html',
    'https://thehighlandcafe.github.io/hioswebcore/restaurant.html',
    'https://thehighlandcafe.github.io/hioswebcore/hotelactivities.html',
    'https://thehighlandcafe.github.io/hioswebcore/roomkey.html',
  ];

  // Corresponding titles for each tab
  final List<String> _titles = [
    'Home',
    'Food',
    'Hotel',
    'Room Key',
  ];

  // Called when user taps a navigation destination
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isLoading = true; // Show loading spinner while new page loads
    });
    // Load the new URL in the webview
    _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(_urls[index])),
    );

    // Timeout fallback: stop loading spinner after 10 seconds max even if page hangs
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Show a dialog informing the user that internet connection is missing
  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text(
          'Unable to load the page. Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close dialog
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if screen width is wide (e.g. tablet/desktop)
    final bool isWideScreen = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          // Display title corresponding to selected tab
          child: Text(
            _titles[_selectedIndex],
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_open_rounded),
            onPressed: () {
              // Open fullscreen menu page when menu icon pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FullscreenMenuPage(),
                ),
              );
            },
          ),
          // Removed dynamic color toggle switch here as requested
        ],
      ),
      body: Row(
        children: [
          // If wide screen, show NavigationRail on the side for navigation
          if (isWideScreen) _buildNavigationRail(isWideScreen),

          // Main content: the webview loading selected URL
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest:
                  URLRequest(url: WebUri(_urls[_selectedIndex])),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform:
                    InAppWebViewOptions(javaScriptEnabled: true), // Enable JS
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller; // Save controller for future URL loads
                  },
                  onLoadStart: (controller, url) {
                    debugPrint('WebView load started: $url');
                    setState(() {
                      _isLoading = true; // Show loading spinner
                    });
                  },
                  onLoadStop: (controller, url) {
                    debugPrint('WebView load stopped: $url');
                    setState(() {
                      _isLoading = false; // Hide loading spinner
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    debugPrint('WebView load error $code: $message');
                    setState(() {
                      _isLoading = false;
                    });
                    _showNoInternetDialog(); // Show dialog on loading failure
                  },
                  onLoadHttpError:
                      (controller, url, statusCode, description) {
                    debugPrint('WebView HTTP error $statusCode: $description');
                    setState(() {
                      _isLoading = false;
                    });
                    // Optional: handle HTTP errors differently here if needed
                  },
                ),
                // Removed CircularProgressIndicator overlay here as requested
              ],
            ),
          ),
        ],
      ),
      // For narrow screens show bottom navigation bar instead of NavigationRail
      bottomNavigationBar: isWideScreen ? null : _buildNavigationBar(),
    );
  }

  // Build NavigationRail widget for wide screens
  NavigationRail _buildNavigationRail(bool isWideScreen) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped, // Call handler when user selects destination
      labelType: isWideScreen
          ? NavigationRailLabelType.all // Show labels on wide screens
          : NavigationRailLabelType.none, // Hide labels on narrow screens (fallback)
      destinations: const [
        NavigationRailDestination(
            icon: Icon(Icons.home_rounded), label: Text('Home')),
        NavigationRailDestination(
            icon: Icon(Icons.restaurant_rounded), label: Text('Food')),
        NavigationRailDestination(
            icon: Icon(Icons.hotel_rounded), label: Text('Hotel')),
        NavigationRailDestination(
            icon: Icon(Icons.key_rounded), label: Text('Room Key')),
      ],
    );
  }

  // Build bottom navigation bar widget for narrow screens
  Widget _buildNavigationBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: const NavigationBarThemeData(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          // Always hide labels in bottom navigation for compactness
        ),
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        height: 60, // Height of the navigation bar
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.restaurant_rounded), label: 'Food'),
          NavigationDestination(icon: Icon(Icons.hotel_rounded), label: 'Hotel'),
          NavigationDestination(icon: Icon(Icons.key_rounded), label: 'Room Key'),
        ],
      ),
    );
  }
}
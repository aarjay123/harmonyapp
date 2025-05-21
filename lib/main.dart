import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'theme_provider.dart';
import 'colour_scheme.dart';
import 'settings/settings_page.dart';
import 'helpcenter/helpcenter_page.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'fullscreen_menu_page.dart';
import 'global_slide_transition_builder.dart'; // For slide animation

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final lightColor = lightDynamic ?? lightColorScheme;
        final darkColor = darkDynamic ?? darkColorScheme;

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Harmony',
              themeMode: themeProvider.themeMode,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: lightColor,
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
                colorScheme: darkColor,
                textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Outfit'),
                pageTransitionsTheme: PageTransitionsTheme(
                  builders: {
                    for (final platform in TargetPlatform.values)
                      platform: GlobalSlidePageTransitionsBuilder(),
                  },
                ),
              ),
              home: const ResponsiveScaffold(),
            );
          },
        );
      },
    );
  }
}

class ResponsiveScaffold extends StatefulWidget {
  const ResponsiveScaffold({super.key});

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _selectedIndex = 0;
  InAppWebViewController? _webViewController;
  bool _isLoading = true;  // Track loading status

  final List<String> _urls = [
    'https://thehighlandcafe.github.io/hioswebcore/welcome.html',
    'https://thehighlandcafe.github.io/hioswebcore/restaurant.html',
    'https://thehighlandcafe.github.io/hioswebcore/hotelactivities.html',
    'https://thehighlandcafe.github.io/hioswebcore/roomkey.html',
  ];

  final List<String> _titles = [
    'Home',
    'Food',
    'Hotel',
    'Room Key',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isLoading = true; // Start loading spinner when changing page
    });
    _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(_urls[index])),
    );
  }

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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _titles[_selectedIndex],
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FullscreenMenuPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWideScreen) _buildNavigationRail(isWideScreen),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(_urls[_selectedIndex])),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(javaScriptEnabled: true),
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      _isLoading = true;
                    });
                  },
                  onLoadStop: (controller, url) {
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    setState(() {
                      _isLoading = false;
                    });
                    _showNoInternetDialog();
                  },
                  onLoadHttpError: (controller, url, statusCode, description) {
                    setState(() {
                      _isLoading = false;
                    });
                    // You can handle HTTP errors here if needed
                  },
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen ? null : _buildNavigationBar(),
    );
  }

  NavigationRail _buildNavigationRail(bool isWideScreen) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelType:
      isWideScreen ? NavigationRailLabelType.all : NavigationRailLabelType.none,
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.home_rounded), label: Text('Home')),
        NavigationRailDestination(icon: Icon(Icons.restaurant_rounded), label: Text('Food')),
        NavigationRailDestination(icon: Icon(Icons.hotel_rounded), label: Text('Hotel')),
        NavigationRailDestination(icon: Icon(Icons.key_rounded), label: Text('Room Key')),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: const NavigationBarThemeData(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        ),
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        height: 60,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.restaurant_rounded), label: 'Food'),
          NavigationDestination(icon: Icon(Icons.hotel_rounded), label: 'Hotel'),
          NavigationDestination(icon: Icon(Icons.key_rounded), label: 'Room Key'),
        ],
      ),
    );
  }
}
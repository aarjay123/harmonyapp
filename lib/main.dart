import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'theme_provider.dart';
import 'colour_scheme.dart';
import 'device_info_helper.dart';
import 'fullscreen_menu_page.dart';
import 'global_slide_transition_builder.dart';

import 'dart:io' show Platform;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppLoader());
}

class AppLoader extends StatefulWidget {
  const AppLoader({Key? key}) : super(key: key);

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  ThemeProvider? _themeProvider;
  bool _error = false;
  bool _dynamicColorSupported = false;

  @override
  void initState() {
    super.initState();
    _initTheme();
  }

  Future<void> _initTheme() async {
    try {
      final supported = await DeviceInfoHelper.supportsDynamicColor();
      _dynamicColorSupported = supported;

      final themeProvider = ThemeProvider(dynamicColorEnabled: supported);
      await themeProvider.loadPreferences();

      if (!supported) {
        themeProvider.dynamicColorEnabled = false;
      }

      setState(() {
        _themeProvider = themeProvider;
        // Removed _loading, so no spinner here
      });
    } catch (e, st) {
      debugPrint('Failed to init theme: $e\n$st');
      setState(() {
        _error = true;
        // Removed _loading, so no spinner here
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error || _themeProvider == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Failed to load preferences')),
        ),
      );
    }
    return ChangeNotifierProvider.value(
      value: _themeProvider!,
      child: MyApp(dynamicColorSupported: _dynamicColorSupported),
    );
  }
}

class MyApp extends StatelessWidget {
  final bool dynamicColorSupported;
  const MyApp({Key? key, required this.dynamicColorSupported}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final themeProvider = Provider.of<ThemeProvider>(context);

        final useDynamic =
            themeProvider.dynamicColorEnabled && dynamicColorSupported;

        final lightColor = useDynamic ? (lightDynamic ?? lightColorScheme) : lightColorScheme;
        final darkColor = useDynamic ? (darkDynamic ?? darkColorScheme) : darkColorScheme;

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
          home: ResponsiveScaffold(dynamicColorSupported: dynamicColorSupported),
        );
      },
    );
  }
}

class ResponsiveScaffold extends StatefulWidget {
  final bool dynamicColorSupported;
  const ResponsiveScaffold({Key? key, required this.dynamicColorSupported}) : super(key: key);

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _selectedIndex = 0;
  InAppWebViewController? _webViewController;
  bool _isLoading = true;

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
      _isLoading = true;
    });
    _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(_urls[index])),
    );

    // Timeout fallback: stop loading spinner after 10 seconds max
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
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
            icon: const Icon(Icons.menu_open_rounded),
            onPressed: () {
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
          if (isWideScreen) _buildNavigationRail(isWideScreen),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest:
                  URLRequest(url: WebUri(_urls[_selectedIndex])),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(javaScriptEnabled: true),
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    debugPrint('WebView load started: $url');
                    setState(() {
                      _isLoading = true;
                    });
                  },
                  onLoadStop: (controller, url) {
                    debugPrint('WebView load stopped: $url');
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    debugPrint('WebView load error $code: $message');
                    setState(() {
                      _isLoading = false;
                    });
                    _showNoInternetDialog();
                  },
                  onLoadHttpError: (controller, url, statusCode, description) {
                    debugPrint(
                        'WebView HTTP error $statusCode: $description');
                    setState(() {
                      _isLoading = false;
                    });
                    // Optional: handle HTTP errors
                  },
                ),
                // Removed CircularProgressIndicator overlay here as requested
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
      labelType: isWideScreen
          ? NavigationRailLabelType.all
          : NavigationRailLabelType.none,
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
          NavigationDestination(
              icon: Icon(Icons.restaurant_rounded), label: 'Food'),
          NavigationDestination(icon: Icon(Icons.hotel_rounded), label: 'Hotel'),
          NavigationDestination(icon: Icon(Icons.key_rounded), label: 'Room Key'),
        ],
      ),
    );
  }
}
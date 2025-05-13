import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'colour_scheme.dart';
import 'settings/settings_page.dart';
import 'helpcenter/helpcenter_page.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Harmony',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Outfit'),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Outfit'),
      ),
      themeMode: themeProvider.themeMode,
      home: const ResponsiveScaffold(),
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
    });
    _webViewController?.loadUrl(
      urlRequest: URLRequest(
        url: WebUri(_urls[index]),
      ),
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
        NavigationRailDestination(icon: Icon(Icons.home_rounded), label: Text('Home')),
        NavigationRailDestination(icon: Icon(Icons.restaurant_rounded), label: Text('Food')),
        NavigationRailDestination(icon: Icon(Icons.hotel_rounded), label: Text('Hotel')),
        NavigationRailDestination(icon: Icon(Icons.key_rounded), label: Text('Room Key')),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.restaurant_rounded), label: 'Food'),
        NavigationDestination(icon: Icon(Icons.hotel_rounded), label: 'Hotel'),
        NavigationDestination(icon: Icon(Icons.key_rounded), label: 'Room Key'),
      ],
    );
  }

  void _handleMenuSelection(String value) {
    if (value == 'settings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      );
    } else if (value == 'help') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HelpcenterPage()),
      );
    }
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'help', child: Text('Help')),
              PopupMenuItem(value: 'blog', child: Text('Visit Blog')),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWideScreen) _buildNavigationRail(isWideScreen),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(_urls[_selectedIndex]),
              ),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                ),
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen ? null : _buildNavigationBar(),
    );
  }
}

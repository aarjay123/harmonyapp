import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'settings/settings_page.dart'; // Ensure this file exists
import 'helpcenter/helpcenter_page.dart'; // Ensure this file exists
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  if (Platform.isIOS || Platform.isMacOS) {
    WebViewPlatform.instance = WebKitWebViewPlatform();
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
      theme: ThemeData.light().copyWith(
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Outfit',
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Outfit',
        ),
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
  late final WebViewController _webViewController;

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

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..loadRequest(Uri.parse(_urls[_selectedIndex]));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _webViewController.loadRequest(Uri.parse(_urls[index]));
  }

  NavigationRail _buildNavigationRail(bool isWideScreen) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelType: isWideScreen
          ? NavigationRailLabelType.all
          : NavigationRailLabelType.none,
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
        NavigationRailDestination(icon: Icon(Icons.restaurant), label: Text('Food')),
        NavigationRailDestination(icon: Icon(Icons.hotel), label: Text('Hotel')),
        NavigationRailDestination(icon: Icon(Icons.key), label: Text('Room Key')),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.restaurant), label: 'Food'),
        NavigationDestination(icon: Icon(Icons.hotel), label: 'Hotel'),
        NavigationDestination(icon: Icon(Icons.key), label: 'Room Key'),
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
    } else if (value == 'blog') {
      // handle blog
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
          Expanded(child: WebViewWidget(controller: _webViewController)),
        ],
      ),
      bottomNavigationBar: isWideScreen ? null : _buildNavigationBar(),
    );
  }
}

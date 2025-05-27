import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/gestures.dart'; // Import for GestureRecognizers
import 'package:flutter/foundation.dart' show Factory; // Import Factory

// A simple page to display a webview in fullscreen
class FullscreenWebViewPage extends StatelessWidget {
  final String url;
  final String title;

  const FullscreenWebViewPage({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          // Add any other settings you need for fullscreen view
        ),
      ),
    );
  }
}

class HiCafePage extends StatefulWidget {
  const HiCafePage({super.key});

  @override
  State<HiCafePage> createState() => _HiCafePageState();
}

class _HiCafePageState extends State<HiCafePage> with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _menusTabController;

  // URLs for iframes
  final String _bookTableFormUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSfeP-cO7te979Dc-QRmUsBwQTzIojYRtg7Yx3OufiiUcn2r2g/viewform?embedded=true';
  final String _orderFoodFormUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSfGzW5su4bVmpeRVGRbDDeudfZkvhbyuXi-pySKLW4qA8WnaA/viewform?embedded=true';

  final Map<String, String> _menuUrls = {
    'Normal': 'https://drive.google.com/file/d/1asnkFiTAX-bancBcS094ge9XE3Q-Bn3d/preview',
    'Worldwide': 'https://drive.google.com/file/d/1ZTnLTPCGjV0MdHNjTP9JJBSW_WdtSm8i/preview',
    'Pizza': 'https://drive.google.com/file/d/1YezhyJuuUg-sghImzB-zWn-wGnI6l8Ww/preview',
    'Gastro': 'https://drive.google.com/file/d/1iHoe-pBMn0niY9R2IoZgYmhgXLaz7Mrz/preview',
  };

  // Define a max width for desktop-like content presentation
  static const double _contentMaxWidth = 768.0;


  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this); // Book, Menus, Order
    _menusTabController = TabController(length: _menuUrls.length, vsync: this); // For different menus
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _menusTabController.dispose();
    super.dispose();
  }

  Widget _buildWebViewSection({
    required String title,
    required String subtitle,
    required String iframeUrl,
    required String fullscreenUrl, // URL for the fullscreen button
    required IconData titleIcon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(titleIcon, size: 28, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(title, style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      )
                    ]
                  ],
                ),
              ),
              Card(
                elevation: 0,
                color: colorScheme.secondaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.fullscreen_rounded, color: colorScheme.onPrimary),
                        label: Text('Open Form Fullscreen', style: TextStyle(color: colorScheme.onPrimary)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullscreenWebViewPage(url: fullscreenUrl, title: title),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 550, // Adjusted height, ensure it's reasonable
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: InAppWebView(
                            key: ValueKey(iframeUrl),
                            initialUrlRequest: URLRequest(url: WebUri(iframeUrl)),
                            initialSettings: InAppWebViewSettings(
                              javaScriptEnabled: true,
                              transparentBackground: true,
                            ),
                            // Add gesture recognizers to allow webview scrolling
                            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                              Factory<VerticalDragGestureRecognizer>(
                                    () => VerticalDragGestureRecognizer(),
                              ),
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTabContent(String menuName, String menuUrl) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: Card(
            elevation: 0,
            color: colorScheme.secondaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '$menuName Menu',
                    style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.fullscreen_rounded, color: colorScheme.onPrimary),
                    label: Text('Open Menu Fullscreen', style: TextStyle(color: colorScheme.onPrimary)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullscreenWebViewPage(url: menuUrl, title: '$menuName Menu'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 550, // Adjusted height
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: InAppWebView(
                        key: ValueKey(menuUrl),
                        initialUrlRequest: URLRequest(url: WebUri(menuUrl)),
                        initialSettings: InAppWebViewSettings(
                          javaScriptEnabled: true,
                          transparentBackground: true,
                        ),
                        // Add gesture recognizers to allow webview scrolling
                        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                          Factory<VerticalDragGestureRecognizer>(
                                () => VerticalDragGestureRecognizer(),
                          ),
                        },
                      ),
                    ),
                  ),
                ],
              ),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your HiCafe™ Visit'),
      ),
      body: Column(
        children: [
          Material(
            color: colorScheme.surface,
            elevation: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: TabBar(
                    controller: _mainTabController,
                    labelColor: colorScheme.onSecondaryContainer,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      color: colorScheme.secondaryContainer,
                    ),
                    splashBorderRadius: BorderRadius.circular(24.0),
                    dividerHeight: 0.0,
                    tabs: const [
                      Tab(text: 'Book'),
                      Tab(text: 'Menus'),
                      Tab(text: 'Order'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                _buildWebViewSection(
                  title: 'Book a Table',
                  subtitle: 'Fill in the below form to book a table, and we\'ll reply within an hour by email.',
                  iframeUrl: _bookTableFormUrl,
                  fullscreenUrl: _bookTableFormUrl.replaceAll("?embedded=true", ""),
                  titleIcon: Icons.table_restaurant_rounded,
                ),
                Column(
                  children: [
                    Material(
                      color: colorScheme.surface,
                      elevation: 0,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                            child: TabBar(
                              controller: _menusTabController,
                              tabAlignment: TabAlignment.fill,
                              labelColor: colorScheme.onTertiaryContainer,
                              unselectedLabelColor: colorScheme.onSurfaceVariant,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(28.0),
                                color: colorScheme.tertiaryContainer,
                              ),
                              splashBorderRadius: BorderRadius.circular(28.0),
                              dividerHeight: 0.0,
                              labelPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                              labelStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 13),
                              tabs: _menuUrls.keys.map((String key) {
                                return Tab(
                                  child: Text(key),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _menusTabController,
                        children: _menuUrls.entries.map((entry) {
                          return _buildMenuTabContent(entry.key, entry.value);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                _buildWebViewSection(
                  title: 'Food Ordering',
                  subtitle: 'Order the food you would like below.',
                  iframeUrl: _orderFoodFormUrl,
                  fullscreenUrl: _orderFoodFormUrl.replaceAll("?embedded=true", ""),
                  titleIcon: Icons.edit_note_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
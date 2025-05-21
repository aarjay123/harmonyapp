import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HelpcenterPage extends StatefulWidget {
  const HelpcenterPage({super.key});

  @override
  State<HelpcenterPage> createState() => _HelpcenterPageState();
}

class _HelpcenterPageState extends State<HelpcenterPage> {
  bool showWebPage = false;
  String currentUrl = '';
  InAppWebViewController? _webViewController;

  Key webViewKey = UniqueKey();

  void _loadWebPage(String url) {
    setState(() {
      currentUrl = url;
      showWebPage = true;
      webViewKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Separate tutorial item
    final _HelpItem tutorialItem = _HelpItem(
      icon: Icons.smartphone,
      title: "App Tutorial",
      url: "https://thehighlandcafe.github.io/hioswebcore/helpcenter/tutorial.html",
    );

    // General items (exclude tutorial and the last 3 more items)
    final List<_HelpItem> generalItems = [
      _HelpItem(
        icon: Icons.restaurant,
        title: "Restaurant",
        url: "https://thehighlandcafe.github.io/hioswebcore/helpcenter/restaurant.html",
      ),
      _HelpItem(
        icon: Icons.hotel,
        title: "Hotel",
        url: "https://thehighlandcafe.github.io/hioswebcore/helpcenter/hotel.html",
      ),
      _HelpItem(
        icon: Icons.vpn_key,
        title: "Room Key",
        url: "https://thehighlandcafe.github.io/hioswebcore/helpcenter/roomkey.html",
      ),
      _HelpItem(
        icon: Icons.support_agent,
        title: "Customer Support",
        url: "https://thehighlandcafe.github.io/hioswebcore/helpcenter/more/support.html",
      ),
      _HelpItem(
        icon: Icons.language,
        title: "Internet",
        url: "https://thehighlandcafe.github.io/hioswebcore/helpcenter/internet.html",
      ),
      _HelpItem(
        icon: Icons.update,
        title: "Updates",
        url: "https://thehighlandcafe.github.io/hioswebcore/helpcenter/updates.html",
      ),
    ];

    // More items
    final List<_HelpItem> moreItems = [
      _HelpItem(
        icon: Icons.new_releases,
        title: "Coming Soon",
        url: "https://sites.google.com/view/x-by-thc-comingsoon",
      ),
      _HelpItem(
        icon: Icons.description,
        title: "Terms & Conditions",
        url: "https://thehighlandcafe.github.io/hioswebcore/helpcenter/more/terms-conditions.html",
      ),
      _HelpItem(
        icon: Icons.feedback,
        title: "App Feedback",
        url: "https://thehighlandcafe.github.io/hioswebcore/helpcenter/more/appfeedback.html",
      ),
    ];

    Widget buildCardList(List<_HelpItem> items) {
      return Column(
        children: List.generate(items.length, (index) {
          final isFirst = index == 0;
          final isLast = index == items.length - 1;
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Material(
              color: colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: isFirst ? const Radius.circular(16) : const Radius.circular(5),
                  bottom: isLast ? const Radius.circular(16) : const Radius.circular(5),
                ),
                //side: BorderSide(color: colorScheme.outline),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _loadWebPage(item.url),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(item.icon, color: colorScheme.primary),
                      const SizedBox(width: 16),
                      Text(
                        item.title,
                        style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),
        leading: showWebPage
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => showWebPage = false),
        )
            : null,
      ),
      body: showWebPage
          ? InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(url: WebUri(currentUrl)),
        initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
      )
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text(
              "Tutorial",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            buildCardList([tutorialItem]),
            const SizedBox(height: 24),
            Text(
              "General",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            buildCardList(generalItems),
            const SizedBox(height: 24),
            Text(
              "More",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            buildCardList(moreItems),
          ],
        ),
      ),
    );
  }
}

class _HelpItem {
  final IconData icon;
  final String title;
  final String url;

  _HelpItem({required this.icon, required this.title, required this.url});
}
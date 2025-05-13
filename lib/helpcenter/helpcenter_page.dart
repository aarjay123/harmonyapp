import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HelpcenterPage extends StatefulWidget {
  const HelpcenterPage({super.key});

  @override
  State<HelpcenterPage> createState() => _HelpcenterPageState();
}

class _HelpcenterPageState extends State<HelpcenterPage> {
  bool showWebPage = false;
  String currentUrl = '';

  late final WebViewController _webViewController;

  void _loadWebPage(String url) {
    setState(() {
      currentUrl = url;
      showWebPage = true;
      _webViewController.loadRequest(Uri.parse(url));
    });
  }

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),
        leading: showWebPage
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            setState(() {
              showWebPage = false;
            });
          },
        )
            : null,
      ),
      body: showWebPage
          ? WebViewWidget(controller: _webViewController)
          : ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.smartphone),
            title: const Text("App Tutorial"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/tutorial.html"),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text("Food Services Help"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/restaurant.html"),
          ),
          ListTile(
            leading: const Icon(Icons.hotel),
            title: const Text("Hotel Help"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/hotel.html"),
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text("Room Key Help"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/roomkey.html"),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text("Customer Support"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/more/support.html"),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Internet Help"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/internet.html"),
          ),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text("Updates Help"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/updates.html"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text("Terms & Conditions"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/more/terms-conditions.html"),
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text("App Feedback"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/more/appfeedback.html"),
          ),
        ],
      ),
    );
  }
}

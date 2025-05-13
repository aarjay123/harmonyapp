import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebsitesPage extends StatelessWidget {
  const WebsitesPage({super.key});

  Future<void> _launchExternalUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch the website.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Websites"),
      ),
      body: ListView(
        children: [
          // Highland Cafe Enterprises
          ListTile(
            leading: const Icon(Icons.business_rounded),
            title: const Text("The Highland Cafe™ Enterprises"),
            subtitle: const Text("Official website for The Highland Cafe™ Enterprises."),
            onTap: () => _launchExternalUrl(context, 'https://hienterprises.github.io'),
          ),

          // Highland Cafe
          ListTile(
            leading: const Icon(Icons.restaurant_rounded),
            title: const Text("The Highland Cafe™"),
            subtitle: const Text("Official website for The Highland Cafe™."),
            onTap: () => _launchExternalUrl(context, 'https://hienterprises.github.io/hicafe/home'),
          ),

          // HiDev
          ListTile(
            leading: const Icon(Icons.developer_mode_rounded),
            title: const Text("HiDev"),
            subtitle: const Text("Official website for HiDev."),
            onTap: () => _launchExternalUrl(context, 'https://sites.google.com/view/nuggetdev'),
          ),

          // Harmony Website
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text("Harmony Website"),
            subtitle: const Text("Official website for the Harmony apps."),
            onTap: () => _launchExternalUrl(context, 'https://hienterprises.github.io/harmony/home'),
          ),
        ],
      ),
    );
  }
}

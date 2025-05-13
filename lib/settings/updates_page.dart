import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  //tile urls
  final String _latestUpdateUrl = 'https://github.com/aarjay123/harmonyapp/releases/latest';

  Future<void> _launchExternalUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
        title: const Text("Updates"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text("Download Harmony Update"),
            subtitle: const Text("Download the latest app installer file.\n1. Tap here, then tap the installer matching your OS.\n2. Install the update how you usually would."),
            onTap: () => _launchExternalUrl(context, _latestUpdateUrl),
          ),
        ]
      ),
    );
  }
}

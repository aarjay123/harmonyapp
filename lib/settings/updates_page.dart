import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  //tile urls
  final String _latestUpdateUrl = 'https://github.com/aarjay123/harmonyapp/releases/latest';

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
          ListTile(
          leading: const Icon(Icons.info),
          title: const Text("This version: 3.0.0"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About Harmony"),
            subtitle: const Text("Harmony is the successor to HiOSMobile -- the app is now based on Flutter, so is adaptive and cross-platform.\nThis app is much faster and easier to maintain than HiOSMobile and HiOSMobile Lite, so we can bring new features to you faster!"),
          ),
        ]
      ),
    );
  }
}

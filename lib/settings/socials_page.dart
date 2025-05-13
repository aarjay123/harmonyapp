import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialsPage extends StatelessWidget {
  const SocialsPage({super.key});

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
        title: const Text("Socials"),
      ),
      body: ListView(
        children: [
          // The Highland Cafe™ Enterprises Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "The Highland Cafe™ Enterprises",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.facebook_rounded),
            title: const Text("Facebook"),
            onTap: () {
              _launchExternalUrl(context, 'https://www.facebook.com/profile.php?id=100095224335357');
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded),
            title: const Text("Instagram"),
            onTap: () {
              _launchExternalUrl(context, 'https://www.instagram.com/thehighlandcafe/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.forum_rounded),
            title: const Text("Threads"),
            onTap: () {
              _launchExternalUrl(context, 'https://www.threads.net/@thehighlandcafe');
            },
          ),

          // HiDev Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              "HiDev",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.facebook_rounded),
            title: const Text("Facebook"),
            onTap: () {
              _launchExternalUrl(context, 'https://www.facebook.com/profile.php?id=61558122144435');
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded),
            title: const Text("Instagram"),
            onTap: () {
              _launchExternalUrl(context, 'https://www.instagram.com/nuggetdev/');
            },
          ),
        ],
      ),
    );
  }
}

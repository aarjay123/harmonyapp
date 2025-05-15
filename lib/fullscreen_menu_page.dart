// fullscreen_menu_page.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings/settings_page.dart';      // Adjust import paths as needed
import 'helpcenter/helpcenter_page.dart'; // Adjust import paths as needed

class FullscreenMenuPage extends StatelessWidget {
  const FullscreenMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 40),
              const Text(
                'Menu',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              _buildMenuOption(context, Icons.download_for_offline_rounded, 'Download Menus', null, url: 'https://www.dropbox.com/scl/fo/7gmlnnjcau1np91ee83ht/h?rlkey=ifj506k3aal7ko7tfecy8oqyq&dl=0'),
              const SizedBox(height: 24),
              _buildMenuOption(context, Icons.settings, 'Settings', const SettingsPage()),
              const SizedBox(height: 24),
              _buildMenuOption(context, Icons.help_outline, 'Help', const HelpcenterPage()),
              const SizedBox(height: 24),
              _buildMenuOption(
                context,
                Icons.web,
                'Visit Blog',
                null,
                url: 'https://hienterprises.blogspot.com',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context, IconData icon, String label, Widget? page, {String? url}) {
    return GestureDetector(
      onTap: () async {
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        } else if (url != null) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch $url')),
            );
          }
        }
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

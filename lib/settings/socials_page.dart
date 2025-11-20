import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialsPage extends StatelessWidget {
  const SocialsPage({super.key});

  Future<void> _launchExternalUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch the website.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // --- Modern Header ---
          SliverAppBar.large(
            title: Text('Socials', style: TextStyle(color: colorScheme.onSurface)),
            backgroundColor: colorScheme.surface,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.indigo.withOpacity(0.2), // Matching the indigo theme from SettingsPage
                      colorScheme.surface,
                    ],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Icon(
                      Icons.public,
                      size: 80,
                      color: Colors.indigo.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- Content ---
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                _buildSectionHeader(context, "The Highland Cafe™ Enterprises"),
                Card(
                  elevation: 0,
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.facebook_rounded, color: colorScheme.primary),
                        title: const Text("Facebook"),
                        trailing: Icon(Icons.open_in_new_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                        onTap: () => _launchExternalUrl(context, 'https://www.facebook.com/profile.php?id=100095224335357'),
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant),
                      ListTile(
                        leading: Icon(Icons.camera_alt_rounded, color: colorScheme.primary),
                        title: const Text("Instagram"),
                        trailing: Icon(Icons.open_in_new_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                        onTap: () => _launchExternalUrl(context, 'https://instagram.com/thehighlandcafe'),
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant),
                      ListTile(
                        leading: Icon(Icons.forum_rounded, color: colorScheme.primary),
                        title: const Text("Threads"),
                        trailing: Icon(Icons.open_in_new_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                        onTap: () => _launchExternalUrl(context, 'https://www.threads.net/@thehighlandcafe'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
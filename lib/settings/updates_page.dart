import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = '${info.version}+${info.buildNumber}';
      });
    }
  }

  final String _latestUpdateUrl = 'https://github.com/aarjay123/harmonyapp/releases/latest';
  final String _autoUpdateUrl = 'https://hienterprises.github.io/harmony/autoupdate';
  final String _discordUrl = 'https://discord.gg/EDykxqwy';

  Future<void> _launchExternalUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
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
            title: Text('Updates', style: TextStyle(color: colorScheme.onSurface)),
            backgroundColor: colorScheme.surface,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.cyan.withOpacity(0.2), // Using Cyan to match your Help Center icons for Updates
                      colorScheme.surface,
                    ],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Icon(
                      Icons.system_update_rounded,
                      size: 80,
                      color: Colors.cyan.withOpacity(0.5),
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

                // --- Update Harmony Group ---
                _buildSectionHeader(context, "Update Harmony"),
                Card(
                  elevation: 0,
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.download_rounded, color: colorScheme.primary),
                        title: const Text("Download from GitHub"),
                        subtitle: const Text("Get the latest version from our official releases page."),
                        trailing: Icon(Icons.open_in_new_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                        onTap: () => _launchExternalUrl(context, _latestUpdateUrl),
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant),
                      ListTile(
                        leading: Icon(Icons.update_rounded, color: colorScheme.primary),
                        title: const Text("Set Up Auto-Updates"),
                        subtitle: const Text("Visit our site to learn how to get automatic updates on Android."),
                        trailing: Icon(Icons.open_in_new_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                        onTap: () => _launchExternalUrl(context, _autoUpdateUrl),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- Stay Informed Group ---
                _buildSectionHeader(context, "Stay Informed"),
                Card(
                  elevation: 0,
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: Icon(Icons.notifications_active_rounded, color: colorScheme.primary),
                    title: const Text("Join our Discord"),
                    subtitle: const Text("Get notified every time we release a new update."),
                    trailing: Icon(Icons.open_in_new_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                    onTap: () => _launchExternalUrl(context, _discordUrl),
                  ),
                ),

                const SizedBox(height: 24),

                // --- Version Information Group ---
                _buildSectionHeader(context, "Version Information"),
                Card(
                  elevation: 0,
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.new_releases_rounded, color: colorScheme.primary),
                        title: const Text("What's New?"),
                        subtitle: const Text("See the official release notes for the latest version."),
                        trailing: Icon(Icons.open_in_new_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                        onTap: () => _launchExternalUrl(context, _latestUpdateUrl),
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant),
                      ListTile(
                        leading: Icon(Icons.info_rounded, color: colorScheme.primary),
                        title: const Text("Current Version"),
                        subtitle: Text("You are running version $_version"),
                        // Informational only, so no trailing icon or tap action needed
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- About Group ---
                _buildSectionHeader(context, "About"),
                Card(
                  elevation: 0,
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("About Harmony", style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                "Harmony is the successor to HiOSMobile -- the app is now based on Flutter, so is adaptive and cross-platform.\n\nThis app is much faster and easier to maintain than HiOSMobile and HiOSMobile Lite, so we can bring new features to you faster!",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
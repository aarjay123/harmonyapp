import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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

  Widget _buildInfoRow(BuildContext context, {required String title, required String value}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Modern Sliver Header with your Logo
          SliverAppBar.large(
            title: Text('About App', style: TextStyle(color: colorScheme.onSurface)),
            backgroundColor: colorScheme.surface,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.withOpacity(0.2),
                      colorScheme.surface
                    ],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.network(
                        'https://thehighlandcafe.github.io/hioswebcore/assets/pics/logos/logo_new-harmony.png',
                        fit: BoxFit.contain,
                        height: 100,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return SizedBox(
                            height: 100,
                            width: 100,
                            child: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if offline
                          return Icon(Icons.image_not_supported_rounded, size: 80, color: colorScheme.onSurfaceVariant);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Info Card
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildInfoRow(context, title: "App Name", value: "Harmony by The Highland Cafe™"),
                          Divider(color: colorScheme.outlineVariant),
                          _buildInfoRow(context, title: "App Version", value: _version),
                          Divider(color: colorScheme.outlineVariant),
                          _buildInfoRow(context, title: "Built With", value: "Flutter"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description Text
                  Text(
                    "Harmony is the successor to HiOSMobile -- the app is now based on Flutter, so is adaptive and cross-platform.\n\nThis app is much faster and easier to maintain than HiOSMobile and HiOSMobile Lite, so we can bring new features to you faster!",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Footer
                  Text(
                    "Copyright © The Highland Cafe™ Ltd. 2025. All Rights Reserved.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
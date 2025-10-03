import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutAppPage extends StatefulWidget {
  const AboutAppPage({super.key});

  @override
  State<AboutAppPage> createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
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

  // Helper widget to build the info rows, similar to the HTML structure.
  Widget _buildInfoRow(BuildContext context, {required String title, required String value}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const double contentMaxWidth = 768.0;

    return Scaffold(
      // FIXED: The AppBar has been added back to the Scaffold.
      appBar: AppBar(
        title: const Text("About App"),
      ),
      // The body is a Column to place the footer at the bottom.
      body: SafeArea(
        child: Column(
          children: [
            // The main content is an Expanded ListView to make it scrollable.
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: contentMaxWidth),
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // --- Header Card ---
                      // This card is no longer needed as the AppBar serves as the header.
                      // const SizedBox(height: 16), // Removed to bring content up.
                      // --- Main Content Card ---
                      Card(
                        elevation: 0,
                        color: colorScheme.surfaceVariant.withOpacity(0.5),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // --- Logo Section ---
                              // UPDATED: Wrapped the Image.network in a ClipRRect to add a corner radius.
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
                                child: Image.network(
                                  'https://thehighlandcafe.github.io/hioswebcore/assets/pics/logos/logo_new-harmony.png',
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const SizedBox(
                                      height: 100,
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              // --- Info Box (like the "translucentAboutBox") ---
                              Card(
                                elevation: 0,
                                color: colorScheme.surface.withOpacity(0.6),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildInfoRow(context, title: "App Name", value: "Harmony by The Highland Cafe™"),
                                      const Divider(),
                                      _buildInfoRow(context, title: "App Version", value: _version),
                                      const Divider(),
                                      _buildInfoRow(context, title: "Built With", value: "Flutter"),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // --- Description Text ---
                              const Text(
                                "Harmony is the successor to HiOSMobile -- the app is now based on Flutter, so is adaptive and cross-platform.\n\nThis app is much faster and easier to maintain than HiOSMobile and HiOSMobile Lite, so we can bring new features to you faster!",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // --- Footer ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Copyright © The Highland Cafe™ Ltd. 2025. All Rights Reserved.",
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
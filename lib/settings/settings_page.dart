import 'package:flutter/material.dart';
import 'package:hiosdesktop/helpcenter/articles/app_feedback_info_page.dart';
import 'package:url_launcher/url_launcher.dart';

// Import your setting sub-pages
import 'appearance_settings_page.dart';
import 'apps_services_page.dart';
import 'about_page.dart';
import 'socials_page.dart';
import 'updates_page.dart';
import 'privacy_policy_page.dart';
// import 'web_settings_page.dart'; // Uncomment if used

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Large Modern Header
          SliverAppBar.large(
            expandedHeight: 200.0,
            pinned: true,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Settings',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primaryContainer.withOpacity(0.5),
                      colorScheme.surface,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.settings_rounded,
                    size: 80,
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader(context, 'General'),
                _buildSettingsCard(context, [
                  _buildTile(
                    context,
                    icon: Icons.palette_rounded,
                    color: Colors.purple,
                    title: 'Appearance',
                    subtitle: 'Themes, customization',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppearanceSettingsPage())),
                  ),
                  /*_buildTile(
                    context,
                    icon: Icons.apps_rounded,
                    color: Colors.orange,
                    title: 'Apps & Services',
                    subtitle: 'Manage integrations',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppsServicesPage())),
                  ),*/
                ]),

                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Information'),
                _buildSettingsCard(context, [
                  _buildTile(
                    context,
                    icon: Icons.info_rounded,
                    color: Colors.blue,
                    title: 'About Harmony',
                    subtitle: 'Version, licenses',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
                  ),
                  _buildTile(
                    context,
                    icon: Icons.update_rounded,
                    color: Colors.green,
                    title: 'Updates',
                    subtitle: 'Check for new versions',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdatesPage())),
                  ),
                  _buildTile(
                    context,
                    icon: Icons.privacy_tip_rounded,
                    color: Colors.teal,
                    title: 'Privacy Policy',
                    subtitle: 'Data usage & terms',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
                  ),
                ]),

                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Community'),
                _buildSettingsCard(context, [

                  _buildTile(
                    context,
                    icon: Icons.public,
                    color: Colors.indigo,
                    title: 'Socials',
                    subtitle: 'Join our community',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SocialsPage())),
                  ),
                  _buildTile(
                    context,
                    icon: Icons.bug_report_rounded,
                    color: Colors.redAccent,
                    title: 'Report an Issue',
                    subtitle: 'Help us improve',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppFeedbackInfoPage()))
                  ),
                ]),

                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'built by nuggetdev',
                    style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildTile(BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
    );
  }
}
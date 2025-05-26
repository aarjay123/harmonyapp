import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings/settings_page.dart';
import 'helpcenter/helpcenter_page.dart';

class FullscreenMenuPage extends StatelessWidget {
  const FullscreenMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              Text(
                'Menu',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 32),
              _buildGroupedMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedMenu(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.download_for_offline_rounded,
        label: 'Download Menus',
        url: 'https://www.dropbox.com/scl/fo/7gmlnnjcau1np91ee83ht/h?rlkey=ifj506k3aal7ko7tfecy8oqyq&dl=0',
      ),
      _MenuItem(
        icon: Icons.settings,
        label: 'Settings',
        page: const SettingsPage(),
      ),
      _MenuItem(
        icon: Icons.help_outline,
        label: 'Help',
        page: const HelpcenterPage(),
      ),
      _MenuItem(
        icon: Icons.web,
        label: 'Visit Blog',
        url: 'https://hienterprises.blogspot.com',
      ),
    ];

    return Column(
      children: List.generate(menuItems.length, (index) {
        final isFirst = index == 0;
        final isLast = index == menuItems.length - 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 1), // small gap between
          child: _buildMenuCard(context, menuItems[index], isFirst, isLast),
        );
      }),
    );
  }

  Widget _buildMenuCard(
      BuildContext context,
      _MenuItem item,
      bool isFirst,
      bool isLast,
      ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.circular(5),
          bottom: isLast ? const Radius.circular(16) : Radius.circular(5),
        ),
        //side: BorderSide(color: colorScheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          if (item.page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item.page!),
            );
          } else if (item.url != null) {
            final uri = Uri.parse(item.url!);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch ${item.url}')),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(item.icon, color: colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Widget? page;
  final String? url;

  _MenuItem({
    required this.icon,
    required this.label,
    this.page,
    this.url,
  });
}

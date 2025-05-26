import 'package:flutter/material.dart';

// Helper class to define the structure of an item data
// This can be used by pages to structure their settings items
class SettingsListItemData {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing; // Added for consistency if needed at data level

  SettingsListItemData({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.trailing, // Added
  });
}

// Reusable widget for displaying a settings group title
class SettingsGroupTitle extends StatelessWidget {
  final String title;

  const SettingsGroupTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
      ),
    );
  }
}

// Reusable widget for displaying a settings list item
class SettingsListItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing; // Added trailing widget
  final bool isFirstItem;
  final bool isLastItem;

  const SettingsListItem({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.trailing, // Added
    this.isFirstItem = false,
    this.isLastItem = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 1.0), // Small gap between items
      child: Material(
        color: colorScheme.secondaryContainer,
        // Apply rounded corners based on item position
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: isFirstItem ? const Radius.circular(16.0) : const Radius.circular(5.0),
            bottom: isLastItem ? const Radius.circular(16.0) : const Radius.circular(5.0),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap, // onTap can be null for non-interactive items
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              // Align icon to top if subtitle exists, otherwise center
              crossAxisAlignment: subtitle != null && trailing == null
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, // Center text vertically if no subtitle
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6.0),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Display trailing widget if provided
                if (trailing != null)
                  trailing!
                // Else, show a chevron if the item is tappable and no trailing widget
                else if (onTap != null)
                  Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
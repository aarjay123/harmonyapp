import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For local data persistence
import 'dart:convert'; // For encoding/decoding JSON
import 'package:url_launcher/url_launcher.dart'; // For opening URLs

/// A card widget allowing users to add, manage, and open custom web links.
class QuickLinksCard extends StatefulWidget {
  const QuickLinksCard({super.key});

  @override
  State<QuickLinksCard> createState() => _QuickLinksCardState();
}

class _QuickLinksCardState extends State<QuickLinksCard> {
  List<Map<String, String>> _links = []; // List to store user-defined links
  final TextEditingController _titleController = TextEditingController(); // Controller for link title input
  final TextEditingController _urlController = TextEditingController();   // Controller for link URL input

  @override
  void initState() {
    super.initState();
    _loadLinks(); // Load saved links when the widget initializes
  }

  @override
  void dispose() {
    _titleController.dispose(); // Dispose controllers to free up resources
    _urlController.dispose();
    super.dispose();
  }

  /// Loads saved links from SharedPreferences.
  /// Links are stored as a JSON string and decoded back into a List of Maps.
  Future<void> _loadLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? linksJson = prefs.getString('quickLinks');
    if (linksJson != null && linksJson.isNotEmpty) {
      final List<dynamic> decoded = json.decode(linksJson);
      setState(() {
        _links = decoded.map((item) => Map<String, String>.from(item)).toList();
      });
    }
  }

  /// Saves the current list of links to SharedPreferences as a JSON string.
  Future<void> _saveLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final String linksJson = json.encode(_links); // Encode list of maps to JSON string
    await prefs.setString('quickLinks', linksJson);
  }

  /// Adds a new link to the list after validating inputs and saves the updated list.
  void _addLink() {
    if (_titleController.text.isNotEmpty && _urlController.text.isNotEmpty) {
      // Basic URL scheme validation: if no scheme (like http/https) is present, prepend https://
      if (!(Uri.tryParse(_urlController.text)?.hasScheme ?? false)) {
        _urlController.text = 'https://${_urlController.text}';
      }

      setState(() {
        _links.add({
          'title': _titleController.text,
          'url': _urlController.text,
        });
      });
      _saveLinks(); // Save the updated list
      _titleController.clear(); // Clear input fields
      _urlController.clear();
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  /// Removes a link at a specific index from the list and saves the updated list.
  void _removeLink(int index) {
    setState(() {
      _links.removeAt(index);
    });
    _saveLinks(); // Save the updated list
  }

  /// Shows a dialog to add a new link.
  void _showAddLinkDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          backgroundColor: colorScheme.surfaceContainerHigh,
          title: Text('Add New Link', style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Make column take minimum space
            children: [
              // TextField for link title
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Link Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 12), // Space between fields
              // TextField for URL
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'URL (e.g., https://example.com)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                keyboardType: TextInputType.url, // Optimize keyboard for URL input
              ),
            ],
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
            ),
            // Add button
            FilledButton(
              onPressed: _addLink,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0, // Flat card design
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      color: colorScheme.tertiaryContainer, // Uses a distinct surface color
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Consistent internal padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row for the Quick Links card
            Row(
              children: [
                Icon(Icons.link_rounded, color: colorScheme.onSurfaceVariant, size: 28),
                const SizedBox(width: 12),
                Text(
                  "Quick Links",
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600
                  ),
                ),
                const Spacer(), // Pushes the add button to the end
                IconButton(
                  icon: Icon(Icons.add_circle_outline_rounded, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                  onPressed: () => _showAddLinkDialog(context), // Shows dialog to add new link
                  tooltip: 'Add New Link',
                )
              ],
            ),
            const SizedBox(height: 16), // Space below header

            // Conditional display based on whether links exist
            _links.isEmpty
                ? Text(
              'No quick links added yet. Tap + to add one!',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
            )
                : Column(
              // Display the list of added links
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_links.length, (index) {
                final link = _links[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0), // Space between links
                  child: InkWell(
                    onTap: () async {
                      // Open the link in an external browser
                      final Uri url = Uri.parse(link['url']!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not open link: ${link['url']}')),
                        );
                      }
                    },
                    onLongPress: () {
                      // Show a confirmation dialog to remove the link on long press
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                          backgroundColor: colorScheme.surfaceContainerHigh,
                          title: Text('Remove Link', style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface)),
                          content: Text('Do you want to remove "${link['title']}"?', style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
                            ),
                            FilledButton(
                              onPressed: () {
                                _removeLink(index); // Remove the link
                                Navigator.of(dialogContext).pop(); // Close dialog
                              },
                              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners for tappable area
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Padding around content within tappable area
                      child: Row(
                        children: [
                          Icon(Icons.link, size: 20, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              link['title']!,
                              style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.open_in_new_rounded, size: 18, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
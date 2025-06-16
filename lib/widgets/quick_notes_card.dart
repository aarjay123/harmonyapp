import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For local data persistence

/// A card widget for quick note-taking with local persistence.
class QuickNotesCard extends StatefulWidget {
  const QuickNotesCard({super.key});

  @override
  State<QuickNotesCard> createState() => _QuickNotesCardState();
}

class _QuickNotesCardState extends State<QuickNotesCard> {
  // MODIFIED: Initialize _notesController directly. It's no longer 'late'.
  TextEditingController _notesController = TextEditingController(text: 'Write your quick notes here...'); // Default text

  @override
  void initState() {
    super.initState();
    // MODIFIED: _loadNotes will now update the text of the already initialized controller.
    _loadNotes(); // Load saved notes when the widget initializes
  }

  @override
  void dispose() {
    _notesController.dispose(); // Dispose the controller to free up resources
    super.dispose();
  }

  /// Loads saved notes from SharedPreferences.
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedNotes = prefs.getString('quickNotes');
    // MODIFIED: Only update controller's text if saved text is different and widget is mounted
    if (savedNotes != null && savedNotes != _notesController.text && mounted) {
      // Use setState to ensure UI updates after async load
      setState(() {
        _notesController.text = savedNotes;
      });
    }
  }

  /// Saves the current notes content to SharedPreferences.
  Future<void> _saveNotes(String notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quickNotes', notes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0, // Flat card design
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.primaryContainer, // Can choose a different color scheme if desired
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Consistent internal padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row for the Quick Notes card
            Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: colorScheme.onPrimaryContainer, size: 28),
                const SizedBox(width: 12),
                Text(
                  "Quick Notes",
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Space below header

            // TextField for notes input
            TextField(
              controller: _notesController,
              keyboardType: TextInputType.multiline, // Allows multiple lines of text
              maxLines: null, // Allows unlimited lines, expands vertically as needed
              minLines: 3, // Minimum height of the text field
              decoration: InputDecoration(
                hintText: 'Type your notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none, // No border for a cleaner look
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant, // Background color for the text field
                contentPadding: const EdgeInsets.all(12.0), // Padding inside the text field
              ),
              style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              cursorColor: colorScheme.primary, // Cursor color
              onChanged: _saveNotes, // Automatically saves notes as the text changes
            ),
            const SizedBox(height: 8), // Space below text field

            // "Clear Notes" button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  _notesController.clear(); // Clears the text field
                  _saveNotes(''); // Clears the saved notes in SharedPreferences
                },
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Clear Notes'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
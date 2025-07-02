import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A model for a single quick action item
class QuickAction {
  final String id;
  final String label;
  final IconData icon;
  final int tabIndex;

  const QuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.tabIndex,
  });
}

// A list of all possible quick actions you might want to offer.
// You can add or remove items from this list.
const List<QuickAction> allAvailableActions = [
  QuickAction(id: 'food', label: 'Order Food', icon: Icons.restaurant_rounded, tabIndex: 1),
  QuickAction(id: 'stay', label: 'Book Stay', icon: Icons.hotel_rounded, tabIndex: 2),
  QuickAction(id: 'roomkey', label: 'View Room Key', icon: Icons.key_rounded, tabIndex: 3),
];

class QuickActionsCard extends StatefulWidget {
  final Function(int) onNavigateToTab;
  const QuickActionsCard({super.key, required this.onNavigateToTab});

  @override
  State<QuickActionsCard> createState() => _QuickActionsCardState();
}

class _QuickActionsCardState extends State<QuickActionsCard> {
  List<QuickAction> _selectedActions = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedActions();
  }

  // Load the user's saved preferences for which actions to show
  Future<void> _loadSelectedActions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedActionIds = prefs.getStringList('selectedQuickActions');

    setState(() {
      if (savedActionIds == null || savedActionIds.isEmpty) {
        // If nothing is saved, show the first two actions by default
        _selectedActions = allAvailableActions.take(2).toList();
      } else {
        // Otherwise, load the actions that the user previously selected
        _selectedActions = allAvailableActions
            .where((action) => savedActionIds.contains(action.id))
            .toList();
      }
    });
  }

  // Show a dialog to let the user pick which actions they want to see
  void _showEditActionsDialog() {
    final theme = Theme.of(context);
    final tempSelectedIds = _selectedActions.map((a) => a.id).toList();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Customize Quick Actions'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: allAvailableActions.map((action) {
                    final isSelected = tempSelectedIds.contains(action.id);
                    return CheckboxListTile(
                      title: Text(action.label),
                      value: isSelected,
                      onChanged: (bool? value) {
                        // UPDATED: Add logic to limit selection to 2
                        if (value == true && tempSelectedIds.length >= 2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You can only select up to 2 actions.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return; // Prevent selecting a third item
                        }

                        setDialogState(() {
                          if (value == true) {
                            tempSelectedIds.add(action.id);
                          } else {
                            tempSelectedIds.remove(action.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setStringList('selectedQuickActions', tempSelectedIds);
                    _loadSelectedActions(); // Reload the actions on the card
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // The main card container
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withAlpha(150),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header: Title and Edit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_rounded, color: theme.colorScheme.onSurfaceVariant),
                  onPressed: _showEditActionsDialog,
                  tooltip: 'Edit Quick Actions',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // UPDATED: Use a SizedBox and Row for consistent height
            SizedBox(
              height: 110, // This fixed height ensures the card size is consistent
              child: _buildActionsContent(),
            )
          ],
        ),
      ),
    );
  }

  /// Builds the content area for the actions, showing either the buttons or a placeholder.
  Widget _buildActionsContent() {
    if (_selectedActions.isEmpty) {
      // Show a placeholder if no actions are selected
      return Center(
        child: Text(
          'No actions selected.\nTap the edit icon to add some.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    // Use a Row with Expanded children to ensure consistent layout for 1 or 2 items
    return Row(
      children: List.generate(2, (index) {
        if (index < _selectedActions.length) {
          // If an action exists for this index, build the button
          final action = _selectedActions[index];
          return Expanded(
            child: _buildQuickActionCard(
              context: context,
              icon: action.icon,
              label: action.label,
              onTap: () => widget.onNavigateToTab(action.tabIndex),
            ),
          );
        }
        // Return an empty container to act as a spacer if there's only one action
        return Expanded(child: Container());
      })
          .expand((widget) => [widget, const SizedBox(width: 16)]) // Add spacing between items
          .toList()
        ..removeLast(), // Remove the last SizedBox
    );
  }

  // Builds the individual action button
  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.primaryContainer,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: colorScheme.onPrimaryContainer),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
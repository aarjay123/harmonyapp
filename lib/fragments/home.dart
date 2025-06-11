// fragments/home.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:shared_preferences/shared_preferences.dart'; // For local data persistence

// IMPORTANT: Ensure your pubspec.yaml includes:
/*
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.1
  intl: ^0.19.0
  geolocator: ^11.0.0
  url_launcher: ^6.2.2
  shared_preferences: ^2.2.0
*/

// --- Import Custom Widgets and Models ---
import '../models/weather_data.dart'; // Import the WeatherData model
import '../widgets/at_a_glance_card.dart'; // Import the extracted AtAGlanceCard
import '../widgets/news_feed_card.dart'; // Import the extracted NewsFeedCard
import '../widgets/quick_notes_card.dart'; // Import the extracted QuickNotesCard
import '../widgets/calendar_card.dart'; // Import the extracted CalendarCard
import '../widgets/quick_links_card.dart'; // Import the extracted QuickLinksCard
import '../widgets/daily_affirmation_card.dart'; // Import the extracted DailyAffirmationCard
// ----------------------------------------


class NativeWelcomePage extends StatefulWidget {
  final Function(int) onNavigateToTab;
  const NativeWelcomePage({super.key, required this.onNavigateToTab});

  @override
  State<NativeWelcomePage> createState() => _NativeWelcomePageState();
}

class _NativeWelcomePageState extends State<NativeWelcomePage> {
  String _greeting = '';
  String _formattedDate = '';
  bool _isInEditMode = false; // State variable for edit mode

  // Max width for the main content area on larger screens
  static const double _contentMaxWidth = 768.0;

  // List to store and manage the order of widget IDs
  // This list defines which widgets are present and their default order.
  List<String> _userWidgetOrder = [
    'weather_card',
    'quick_actions',
    'news_feed',
    'quick_notes',
    'calendar_card',
    'quick_links',
    'daily_affirmation',
  ];

  // Map to associate widget IDs with their respective builder functions.
  // This allows dynamic creation and management of widgets based on their string ID.
  late final Map<String, Widget Function(BuildContext)> _availableWidgets;

  @override
  void initState() {
    super.initState();
    _updateGreetingAndDate(); // Set initial greeting and date
    // Initialize _availableWidgets BEFORE _loadUserWidgetOrder, as _loadUserWidgetOrder
    // depends on _availableWidgets being populated to filter saved IDs.
    _availableWidgets = {
      'weather_card': (context) => AtAGlanceCard(formattedDate: _formattedDate), // Using extracted widget
      'quick_actions': (context) => Column( // This is the 'Quick Actions' row
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Order Food',
                  onTap: () => widget.onNavigateToTab(1), // Navigates to a different tab
                ),
              ),
              const SizedBox(width: 16), // Horizontal space between action cards
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  icon: Icons.hotel_rounded,
                  label: 'Book Stay',
                  onTap: () => widget.onNavigateToTab(2), // Navigates to a different tab
                ),
              ),
            ],
          ),
        ],
      ),
      'news_feed': (context) => const NewsFeedCard(), // Using extracted widget
      'quick_notes': (context) => const QuickNotesCard(), // Using extracted widget
      'calendar_card': (context) => const CalendarCard(), // Using extracted widget
      'quick_links': (context) => const QuickLinksCard(), // Using extracted widget
      'daily_affirmation': (context) => const DailyAffirmationCard(), // Using extracted widget
    };
    _loadUserWidgetOrder(); // Load saved widget order from persistence
  }

  /// Loads the user's customized widget order from SharedPreferences.
  /// It also handles cases where new default widgets are added or old ones are removed.
  Future<void> _loadUserWidgetOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedOrder = prefs.getStringList('userWidgetOrder');

    if (savedOrder != null && savedOrder.isNotEmpty) {
      setState(() {
        // Filter out any widget IDs from the saved order that no longer exist in _availableWidgets.
        _userWidgetOrder = savedOrder.where((id) => _availableWidgets.containsKey(id)).toList();

        // Add any new default widgets that are not present in the loaded (and filtered) order.
        final List<String> currentDefaultWidgets = [
          'weather_card',
          'quick_actions',
          'news_feed',
          'quick_notes',
          'calendar_card',
          'quick_links',
          'daily_affirmation',
        ];
        for (String defaultId in currentDefaultWidgets) {
          if (!_userWidgetOrder.contains(defaultId)) {
            _userWidgetOrder.add(defaultId);
          }
        }
      });
    }
  }

  /// Saves the current order of widgets to SharedPreferences for persistence.
  Future<void> _saveUserWidgetOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('userWidgetOrder', _userWidgetOrder);
  }

  /// Updates the greeting message based on the current time of day.
  void _updateGreetingAndDate() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour < 17) {
      _greeting = 'Good Afternoon';
    } else {
      _greeting = 'Good Evening';
    }
    _formattedDate = DateFormat('EEEE, d MMMM').format(now); // Format example: "Monday, 10 June"
    if (mounted) setState(() {}); // Update UI if the widget is still active
  }


  /// Helper function to build the quick action cards found in the 'quick_actions' row.
  /// This remains in `home.dart` as its layout (Expanded cards in a Row) is specific
  /// to the overall home page structure.
  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0, // Flat card design
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.primaryContainer, // Uses primary container color
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:12.0, vertical: 20.0), // Internal padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: colorScheme.onPrimaryContainer),
              const SizedBox(height: 12), // Space between icon and text
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a modal bottom sheet to allow users to add new widgets to the home page.
  void _showAddWidgetDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        // Filter out widgets that are already on the home page
        final List<String> widgetsToAdd = _availableWidgets.keys
            .where((id) => !_userWidgetOrder.contains(id))
            .toList();

        // Display a message if no more widgets are available to add
        if (widgetsToAdd.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.widgets_rounded, size: 48, color: colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  'No more widgets to add!',
                  style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => Navigator.pop(context), // Close the dialog
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }

        // Display the list of available widgets to add
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Widget',
                style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 16),
              Expanded( // Ensures the ListView takes available space in the bottom sheet
                child: ListView.builder(
                  shrinkWrap: true, // Allows ListView to take only as much space as its children
                  itemCount: widgetsToAdd.length,
                  itemBuilder: (context, index) {
                    final widgetId = widgetsToAdd[index];
                    String displayName;
                    // Define user-friendly display names for each widget ID
                    switch (widgetId) {
                      case 'weather_card': displayName = 'At a Glance (Weather & Date)'; break;
                      case 'quick_actions': displayName = 'Quick Actions'; break;
                      case 'news_feed': displayName = 'Latest News'; break;
                      case 'quick_notes': displayName = 'Quick Notes'; break;
                      case 'calendar_card': displayName = 'My Calendar'; break;
                      case 'quick_links': displayName = 'Quick Links'; break;
                      case 'daily_affirmation': displayName = 'Daily Affirmation'; break;
                      default: displayName = widgetId; // Fallback for unknown IDs
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: colorScheme.surfaceVariant,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      child: ListTile(
                        title: Text(displayName, style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                        trailing: Icon(Icons.add_circle_outline, color: colorScheme.primary),
                        onTap: () {
                          setState(() {
                            _userWidgetOrder.add(widgetId); // Add widget to the user's order
                          });
                          _saveUserWidgetOrder(); // Save the new order
                          Navigator.pop(context); // Close the dialog
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows a confirmation dialog before removing a widget from the home page.
  void _showRemoveWidgetDialog(String widgetIdToRemove, String displayName) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          backgroundColor: colorScheme.surfaceContainerHigh,
          title: Text(
            'Remove Widget',
            style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
          ),
          content: Text(
            'Are you sure you want to remove "$displayName" from your home page?',
            style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _userWidgetOrder.remove(widgetIdToRemove); // Remove widget from order
                });
                _saveUserWidgetOrder(); // Save the updated order
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('Remove'),
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

    // Shader for the gradient greeting text
    final Shader greetingGradientShader = LinearGradient(
      colors: <Color>[colorScheme.primary, colorScheme.tertiary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 100.0));

    return Scaffold(
      backgroundColor: colorScheme.surface, // Page background color
      // Pull-to-refresh functionality for the whole page
      body: RefreshIndicator(
        onRefresh: () async {
          // This refresh indicator only triggers its callback.
          // Individual widgets (like NewsFeedCard or AtAGlanceCard) are responsible
          // for refreshing their own data when they are initialized or via their own refresh buttons.
          // For a global refresh, you'd typically use a state management solution (Provider, Riverpod, BLoC).
          // For now, this just visually indicates a refresh, but doesn't force re-fetch on all children.
          // The AtAGlanceCard implicitly handles its own refresh when its parent is rebuilt/state changed.
        },
        color: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: CustomScrollView( // Allows for flexible scrolling and app bar effects
          slivers: [
            // MODIFIED: Increased top padding to push content further down
            const SliverPadding(
              padding: EdgeInsets.only(top: 48.0), // Increased from 24.0 to 48.0
            ),
            SliverAppBar(
              // MODIFIED: Adjusted expandedHeight to bring widgets closer to the title text
              expandedHeight: _isInEditMode ? 80.0 : 100.0, // Reduced from 90/120 to 80/100
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dynamic greeting or "Edit Mode" text
                      Text(
                        _isInEditMode ? 'Edit Mode' : '$_greeting!',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          foreground: Paint()..shader = greetingGradientShader, // Apply gradient
                        ),
                      ),
                      // "Welcome to Harmony!" subtitle, hidden in edit mode
                      if (!_isInEditMode)
                        const SizedBox(height: 4),
                      if (!_isInEditMode)
                        Text(
                          'Welcome to Harmony!',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              backgroundColor: colorScheme.surface, // App bar background
              elevation: 0, // No shadow for the app bar
              pinned: false, // App bar scrolls away with the content
              // Actions in the app bar (only visible in edit mode)
              actions: _isInEditMode
                  ? [
                IconButton(
                  icon: Icon(Icons.done_rounded, color: colorScheme.primary),
                  onPressed: () {
                    setState(() {
                      _isInEditMode = false; // Exit edit mode
                    });
                  },
                  tooltip: 'Done Editing',
                ),
              ]
                  : null, // No actions when not in edit mode
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                    child: ReorderableListView.builder(
                      shrinkWrap: true, // Prevents excessive height
                      physics: const NeverScrollableScrollPhysics(), // Handled by CustomScrollView
                      buildDefaultDragHandles: false, // Crucial: Disable default drag handles to use custom ones
                      itemCount: _userWidgetOrder.length,
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final String item = _userWidgetOrder.removeAt(oldIndex);
                          _userWidgetOrder.insert(newIndex, item);
                        });
                        _saveUserWidgetOrder(); // Save the new order after reorder
                      },
                      itemBuilder: (BuildContext context, int index) {
                        final String widgetId = _userWidgetOrder[index];
                        final Widget? widgetToDisplay = _availableWidgets[widgetId]?.call(context);
                        String displayName;
                        // Map widget IDs to user-friendly names for dialogs/feedback
                        switch (widgetId) {
                          case 'weather_card': displayName = 'At a Glance (Weather & Date)'; break;
                          case 'quick_actions': displayName = 'Quick Actions'; break;
                          case 'news_feed': displayName = 'Latest News'; break;
                          case 'quick_notes': displayName = 'Quick Notes'; break;
                          case 'calendar_card': displayName = 'My Calendar'; break;
                          case 'quick_links': displayName = 'Quick Links'; break;
                          case 'daily_affirmation': displayName = 'Daily Affirmation'; break;
                          default: displayName = widgetId;
                        }

                        if (widgetToDisplay != null) {
                          Widget itemContent = Padding(
                            padding: const EdgeInsets.only(bottom: 24.0), // Space between widgets
                            child: Stack(
                              children: [
                                widgetToDisplay, // The actual widget content
                                // Remove button, visible only in edit mode
                                if (_isInEditMode)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showRemoveWidgetDialog(widgetId, displayName);
                                      },
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: theme.colorScheme.errorContainer,
                                        child: Icon(Icons.remove_rounded, size: 18, color: theme.colorScheme.onErrorContainer),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );

                          // Wrap widget content for reordering and drag handle only in edit mode
                          if (_isInEditMode) {
                            return ReorderableDelayedDragStartListener(
                              key: ValueKey(widgetId), // Unique key is required for ReorderableListView
                              index: index,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start, // Align to top
                                children: [
                                  Expanded(child: itemContent), // Widget content takes most space
                                  // Custom drag handle, visible only in edit mode
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                                    child: Icon(Icons.drag_handle_rounded, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // When not in edit mode, display content without drag functionality
                            return SizedBox( // Still requires a key for ListView's internal management
                              key: ValueKey(widgetId),
                              child: itemContent,
                            );
                          }
                        }
                        return const SizedBox.shrink(); // Return an empty widget if ID is not found
                      },
                    ),
                  ),
                ),
              ),
            ),
            // "Add New Widget" button, visible only in edit mode
            if (_isInEditMode)
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: FilledButton.tonalIcon(
                        onPressed: _showAddWidgetDialog,
                        icon: const Icon(Icons.add_box_rounded), // Icon for adding
                        label: const Text('Add New Widget'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Button to toggle edit mode, always visible at the bottom of the scroll view
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                    child: FilledButton.tonal(
                      onPressed: () {
                        setState(() {
                          _isInEditMode = !_isInEditMode; // Toggle edit mode state
                        });
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      child: Text(_isInEditMode ? 'Exit Edit Mode' : 'Edit Widgets'), // Dynamic button text
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
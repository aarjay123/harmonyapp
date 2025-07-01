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
  static const double _contentMaxWidth = 1200.0; // Increased for wider layouts
  // Breakpoint for switching to two-column layout
  static const double _twoColumnBreakpoint = 768.0;

  // List to store and manage the order of widget IDs
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
  late final Map<String, Widget Function(BuildContext)> _availableWidgets;

  @override
  void initState() {
    super.initState();
    _updateGreetingAndDate();
    _availableWidgets = {
      'weather_card': (context) => AtAGlanceCard(formattedDate: _formattedDate),
      'quick_actions': (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Order Food',
                  onTap: () => widget.onNavigateToTab(1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  context: context,
                  icon: Icons.hotel_rounded,
                  label: 'Book Stay',
                  onTap: () => widget.onNavigateToTab(2),
                ),
              ),
            ],
          ),
        ],
      ),
      'news_feed': (context) => const NewsFeedCard(),
      'quick_notes': (context) => const QuickNotesCard(),
      'calendar_card': (context) => const CalendarCard(),
      'quick_links': (context) => const QuickLinksCard(),
      'daily_affirmation': (context) => const DailyAffirmationCard(),
    };
    _loadUserWidgetOrder();
  }

  Future<void> _loadUserWidgetOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedOrder = prefs.getStringList('userWidgetOrder');

    if (savedOrder != null && savedOrder.isNotEmpty) {
      setState(() {
        _userWidgetOrder = savedOrder.where((id) => _availableWidgets.containsKey(id)).toList();
        final List<String> currentDefaultWidgets = [
          'weather_card', 'quick_actions', 'news_feed', 'quick_notes',
          'calendar_card', 'quick_links', 'daily_affirmation',
        ];
        for (String defaultId in currentDefaultWidgets) {
          if (!_userWidgetOrder.contains(defaultId)) {
            _userWidgetOrder.add(defaultId);
          }
        }
      });
    }
  }

  Future<void> _saveUserWidgetOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('userWidgetOrder', _userWidgetOrder);
  }

  void _updateGreetingAndDate() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour < 12) _greeting = 'Good Morning';
    else if (hour < 17) _greeting = 'Good Afternoon';
    else _greeting = 'Good Evening';
    _formattedDate = DateFormat('EEEE, d MMMM').format(now);
    if (mounted) setState(() {});
  }

  Widget _buildQuickActionCard({
    required BuildContext context, required IconData icon,
    required String label, required VoidCallback onTap,
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
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: colorScheme.onPrimaryContainer),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MODIFIED: Restored the full implementation of the dialog methods.
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
        final List<String> widgetsToAdd = _availableWidgets.keys
            .where((id) => !_userWidgetOrder.contains(id))
            .toList();

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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }

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
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widgetsToAdd.length,
                  itemBuilder: (context, index) {
                    final widgetId = widgetsToAdd[index];
                    String displayName;
                    switch (widgetId) {
                      case 'weather_card': displayName = 'At a Glance'; break;
                      case 'quick_actions': displayName = 'Quick Actions'; break;
                      case 'news_feed': displayName = 'Latest News'; break;
                      case 'quick_notes': displayName = 'Quick Notes'; break;
                      case 'calendar_card': displayName = 'My Calendar'; break;
                      case 'quick_links': displayName = 'Quick Links'; break;
                      case 'daily_affirmation': displayName = 'Daily Affirmation'; break;
                      default: displayName = widgetId;
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
                          setState(() => _userWidgetOrder.add(widgetId));
                          _saveUserWidgetOrder();
                          Navigator.pop(context);
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
            ),
            FilledButton(
              onPressed: () {
                setState(() => _userWidgetOrder.remove(widgetIdToRemove));
                _saveUserWidgetOrder();
                Navigator.of(dialogContext).pop();
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

  /// Builds the content for a single widget tile, including the remove button for edit mode.
  Widget _buildWidgetTile(BuildContext context, String widgetId) {
    final theme = Theme.of(context);
    final widgetToDisplay = _availableWidgets[widgetId]?.call(context);

    if (widgetToDisplay == null) {
      return const SizedBox.shrink();
    }

    String displayName;
    switch (widgetId) {
      case 'weather_card': displayName = 'At a Glance'; break;
      case 'quick_actions': displayName = 'Quick Actions'; break;
      case 'news_feed': displayName = 'Latest News'; break;
      case 'quick_notes': displayName = 'Quick Notes'; break;
      case 'calendar_card': displayName = 'My Calendar'; break;
      case 'quick_links': displayName = 'Quick Links'; break;
      case 'daily_affirmation': displayName = 'Daily Affirmation'; break;
      default: displayName = widgetId;
    }

    return Stack(
      key: ValueKey(widgetId),
      children: [
        widgetToDisplay,
        if (_isInEditMode)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showRemoveWidgetDialog(widgetId, displayName),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: theme.colorScheme.errorContainer,
                child: Icon(Icons.remove_rounded, size: 18, color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the single-column layout with reordering functionality for smaller screens.
  Widget _buildSingleColumnLayout(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: _userWidgetOrder.length,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final String item = _userWidgetOrder.removeAt(oldIndex);
          _userWidgetOrder.insert(newIndex, item);
        });
        _saveUserWidgetOrder();
      },
      itemBuilder: (context, index) {
        final widgetId = _userWidgetOrder[index];
        final itemContent = Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: _buildWidgetTile(context, widgetId),
        );

        if (_isInEditMode) {
          return ReorderableDelayedDragStartListener(
            key: ValueKey(widgetId),
            index: index,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: itemContent),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: Icon(Icons.drag_handle_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
                ),
              ],
            ),
          );
        } else {
          return SizedBox(key: ValueKey(widgetId), child: itemContent);
        }
      },
    );
  }

  /// Builds the two-column dashboard layout for larger screens.
  Widget _buildTwoColumnLayout(BuildContext context, BoxConstraints constraints) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 24.0,
      children: _userWidgetOrder.map((widgetId) {
        final itemWidth = (constraints.maxWidth / 2) - 8.0;
        return SizedBox(
          width: itemWidth,
          child: _buildWidgetTile(context, widgetId),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Shader greetingGradientShader = LinearGradient(
      colors: <Color>[colorScheme.primary, colorScheme.tertiary],
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 100.0));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async { /* ... */ },
        color: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: _isInEditMode ? 120.0 : 150.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isInEditMode ? 'Edit Mode' : '$_greeting!',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          foreground: Paint()..shader = greetingGradientShader,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      if (!_isInEditMode) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Welcome to Harmony!',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              backgroundColor: colorScheme.surface,
              elevation: 0,
              pinned: false,
              actions: _isInEditMode ? [
                IconButton(
                  icon: Icon(Icons.done_rounded, color: colorScheme.primary),
                  onPressed: () => setState(() => _isInEditMode = false),
                  tooltip: 'Done Editing',
                ),
              ] : null,
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= _twoColumnBreakpoint) {
                          return _buildTwoColumnLayout(context, constraints);
                        } else {
                          return _buildSingleColumnLayout(context);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (_isInEditMode)
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                      child: FilledButton.tonalIcon(
                        onPressed: _showAddWidgetDialog,
                        icon: const Icon(Icons.add_box_rounded),
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
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 24.0),
                    child: FilledButton.tonal(
                      onPressed: () => setState(() => _isInEditMode = !_isInEditMode),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      child: Text(_isInEditMode ? 'Exit Edit Mode' : 'Edit Widgets'),
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

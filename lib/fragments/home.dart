import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:reorderable_grid_view/reorderable_grid_view.dart'; // For the reorderable grid
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
  reorderable_grid_view: ^2.2.6 # Added for two-column reordering
*/

// --- Import Custom Widgets and Models ---
import '../models/weather_data.dart'; // Import the WeatherData model
import '../widgets/at_a_glance_card.dart'; // Import the extracted AtAGlanceCard
import '../widgets/news_feed_card.dart'; // Import the extracted NewsFeedCard
import '../widgets/quick_notes_card.dart'; // Import the extracted QuickNotesCard
import '../widgets/calendar_card.dart'; // Import the extracted CalendarCard
import '../widgets/quick_links_card.dart'; // Import the extracted QuickLinksCard
import '../widgets/daily_affirmation_card.dart'; // Import the extracted DailyAffirmationCard
import '../widgets/quick_actions_card.dart'; // Import the new QuickActionsCard
// ----------------------------------------

/// Model to hold metadata for each dashboard widget.
/// This simplifies management by removing the need for switch statements.
class DashboardWidgetModel {
  final String id;
  final String displayName;
  final WidgetBuilder builder;

  DashboardWidgetModel({
    required this.id,
    required this.displayName,
    required this.builder,
  });
}

class NativeWelcomePage extends StatefulWidget {
  final Function(int) onNavigateToTab;
  const NativeWelcomePage({super.key, required this.onNavigateToTab});

  @override
  State<NativeWelcomePage> createState() => _NativeWelcomePageState();
}

class _NativeWelcomePageState extends State<NativeWelcomePage> {
  String _greeting = '';
  String _formattedDate = '';
  bool _isInEditMode = false;

  static const double _contentMaxWidth = 1200.0;
  static const double _twoColumnBreakpoint = 768.0;

  List<String> _userWidgetOrder = [];

  // REFACTORED: Now a map of widget IDs to a model containing all widget info.
  late final Map<String, DashboardWidgetModel> _availableWidgets;

  @override
  void initState() {
    super.initState();
    _updateGreetingAndDate();

    // REFACTORED: Widget definitions now use the DashboardWidgetModel.
    _availableWidgets = {
      'weather_card': DashboardWidgetModel(
        id: 'weather_card',
        displayName: 'At a Glance',
        builder: (context) => AtAGlanceCard(formattedDate: _formattedDate),
      ),
      // UPDATED: Replaced inline implementation with the new QuickActionsCard widget.
      'quick_actions': DashboardWidgetModel(
        id: 'quick_actions',
        displayName: 'Quick Actions',
        builder: (context) => QuickActionsCard(onNavigateToTab: widget.onNavigateToTab),
      ),
      'news_feed': DashboardWidgetModel(
        id: 'news_feed',
        displayName: 'Latest News',
        builder: (context) => const NewsFeedCard(),
      ),
      'quick_notes': DashboardWidgetModel(
        id: 'quick_notes',
        displayName: 'Quick Notes',
        builder: (context) => const QuickNotesCard(),
      ),
      'calendar_card': DashboardWidgetModel(
        id: 'calendar_card',
        displayName: 'My Calendar',
        builder: (context) => const CalendarCard(),
      ),
      'quick_links': DashboardWidgetModel(
        id: 'quick_links',
        displayName: 'Quick Links',
        builder: (context) => const QuickLinksCard(),
      ),
      'daily_affirmation': DashboardWidgetModel(
        id: 'daily_affirmation',
        displayName: 'Daily Affirmation',
        builder: (context) => const DailyAffirmationCard(),
      ),
    };
    _loadUserWidgetOrder();
  }

  Future<void> _loadUserWidgetOrder() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedOrder = prefs.getStringList('userWidgetOrder');

    if (savedOrder == null || savedOrder.isEmpty) {
      // If no order is saved, use the default order from available widgets
      savedOrder = _availableWidgets.keys.toList();
    }

    if (mounted) {
      setState(() {
        // Ensure all saved widgets still exist and add any new default widgets.
        _userWidgetOrder = savedOrder!.where((id) => _availableWidgets.containsKey(id)).toList();
        for (String defaultId in _availableWidgets.keys) {
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
        final List<DashboardWidgetModel> widgetsToAdd = _availableWidgets.values
            .where((model) => !_userWidgetOrder.contains(model.id))
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
                    final widgetModel = widgetsToAdd[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: colorScheme.surfaceVariant,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      child: ListTile(
                        title: Text(widgetModel.displayName, style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                        trailing: Icon(Icons.add_circle_outline, color: colorScheme.primary),
                        onTap: () {
                          setState(() => _userWidgetOrder.add(widgetModel.id));
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
    final model = _availableWidgets[widgetId];

    if (model == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      key: ValueKey(widgetId),
      clipBehavior: Clip.none, // Allow the remove button to overflow the card bounds slightly
      children: [
        model.builder(context),
        Positioned(
          top: -4,
          right: -4,
          child: AnimatedOpacity(
            opacity: _isInEditMode ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !_isInEditMode,
              child: GestureDetector(
                onTap: () => _showRemoveWidgetDialog(model.id, model.displayName),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.errorContainer,
                  child: Icon(Icons.remove_rounded, size: 18, color: theme.colorScheme.onErrorContainer),
                ),
              ),
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
                AnimatedOpacity(
                  opacity: _isInEditMode ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                    child: Icon(Icons.drag_handle_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  ),
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
    if (!_isInEditMode) {
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

    return ReorderableGridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 24.0,
        childAspectRatio: 0.9,
      ),
      itemCount: _userWidgetOrder.length,
      itemBuilder: (context, index) {
        final widgetId = _userWidgetOrder[index];
        return SizedBox(
          key: ValueKey(widgetId),
          child: _buildWidgetTile(context, widgetId),
        );
      },
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          final String item = _userWidgetOrder.removeAt(oldIndex);
          _userWidgetOrder.insert(newIndex, item);
        });
        _saveUserWidgetOrder();
      },
    );
  }

  /// Builds an "empty state" UI when no widgets are present.
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.widgets_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Your dashboard is empty',
              style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Enter edit mode to add new widgets and customize your view.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// **UPDATED**: Builds the new header consistent with the HiCard app style.
  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [colorScheme.primary, colorScheme.tertiary],
                  ).createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: Text(
                    _isInEditMode ? 'Edit Mode' : _greeting,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!_isInEditMode)
                  Text(
                    'Welcome to Harmony!',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          // Add the "Done" button here, visible only in edit mode
          if (_isInEditMode)
            IconButton(
              icon: Icon(Icons.done_rounded, color: colorScheme.primary),
              onPressed: () => setState(() => _isInEditMode = false),
              tooltip: 'Done Editing',
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // **UPDATED**: The body is now wrapped in a SafeArea widget.
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _updateGreetingAndDate();
            });
          },
          color: colorScheme.primary,
          backgroundColor: colorScheme.surfaceContainerHighest,
          child: CustomScrollView(
            slivers: [
              // **UPDATED**: The SliverAppBar has been replaced with the new header widget.
              SliverToBoxAdapter(
                child: _buildHeader(context),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (_userWidgetOrder.isEmpty) {
                            return _buildEmptyState(context);
                          }

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
      ),
    );
  }
}

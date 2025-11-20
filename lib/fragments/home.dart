import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// --- Import Custom Widgets and Models ---
import '../models/weather_data.dart';
import '../widgets/at_a_glance_card.dart';
import '../widgets/news_feed_card.dart';
import '../widgets/quick_notes_card.dart';
import '../widgets/calendar_card.dart';
import '../widgets/quick_links_card.dart';
import '../widgets/daily_affirmation_card.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/countdown_card.dart'; // This now contains the CountdownEvent model
import '../widgets/todo_list_card.dart';
import '../widgets/youtube_card.dart';
// ----------------------------------------

/// Model to hold metadata for each dashboard widget.
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
  // NEW: State variable to manage the initial loading process.
  bool _isLoading = true;

  static const double _contentMaxWidth = 1200.0;
  static const double _twoColumnBreakpoint = 768.0;

  List<String> _userWidgetOrder = [];
  List<CountdownEvent> _allCountdownEvents = [];
  late Map<String, DashboardWidgetModel> _availableWidgets;

  @override
  void initState() {
    super.initState();
    // UPDATED: All initialization logic is now in a single, robust method.
    _initializeDashboard();
  }

  // NEW: Consolidated initialization method to prevent race conditions.
  Future<void> _initializeDashboard() async {
    // This part is synchronous and can run first.
    _updateGreetingAndDate();

    // 1. Load all asynchronous data from shared preferences.
    final prefs = await SharedPreferences.getInstance();
    final eventsString = prefs.getString('countdownEventsList');
    final savedOrder = prefs.getStringList('userWidgetOrder');

    // 2. Process the loaded data into state variables.
    if (eventsString != null) {
      final List<dynamic> eventsJson = json.decode(eventsString);
      _allCountdownEvents = eventsJson.map((json) => CountdownEvent.fromJson(json)).toList();
    }

    // 3. Build the available widgets map now that all data is ready.
    _buildAvailableWidgets();

    // 4. Determine the final widget order.
    List<String> finalOrder;
    if (savedOrder == null || savedOrder.isEmpty) {
      finalOrder = _availableWidgets.keys.toList();
    } else {
      // Filter saved order to ensure all widgets still exist.
      finalOrder = savedOrder.where((id) => _availableWidgets.containsKey(id)).toList();
      // Add any new widgets that might have been introduced in an update.
      for (String defaultId in _availableWidgets.keys) {
        if (!finalOrder.contains(defaultId)) {
          finalOrder.add(defaultId);
        }
      }
    }

    // 5. Set the final state once all data is processed.
    if (mounted) {
      setState(() {
        _userWidgetOrder = finalOrder;
        _isLoading = false; // Turn off the loading indicator
      });
    }
  }


  // This method is now separate to be rebuilt if state changes.
  void _buildAvailableWidgets() {
    _availableWidgets = {
      'weather_card': DashboardWidgetModel(
        id: 'weather_card',
        displayName: 'At a Glance',
        builder: (context) => AtAGlanceCard(formattedDate: _formattedDate),
      ),
      'quick_actions': DashboardWidgetModel(
        id: 'quick_actions',
        displayName: 'Quick Actions',
        builder: (context) => QuickActionsCard(onNavigateToTab: widget.onNavigateToTab),
      ),
      if (!kIsWeb)
        'news_feed': DashboardWidgetModel(
          id: 'news_feed',
          displayName: 'Latest News',
          builder: (context) => const NewsFeedCard(),
        ),
      /*if (!kIsWeb)
        'youtube_card': DashboardWidgetModel(
          id: 'youtube_card',
          displayName: 'Videos',
          builder: (context) => const YoutubeCard(),
        ),*/
      'quick_notes': DashboardWidgetModel(
        id: 'quick_notes',
        displayName: 'Quick Notes',
        builder: (context) => const QuickNotesCard(),
      ),
      'calendar_card': DashboardWidgetModel(
        id: 'calendar_card',
        displayName: 'My Calendar',
        builder: (context) => CalendarCard(events: _allCountdownEvents),
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
      'countdown': DashboardWidgetModel(
        id: 'countdown',
        displayName: 'Countdowns',
        builder: (context) => CountdownCard(onEventsUpdated: _updateEvents),
      ),
      'todo_list': DashboardWidgetModel(
        id: 'todo_list',
        displayName: 'To-Do List',
        builder: (context) => const TodoListCard(),
      ),
    };
  }

  // --- Event State Management ---
  void _updateEvents(List<CountdownEvent> updatedEvents) {
    setState(() {
      _allCountdownEvents = updatedEvents;
      _buildAvailableWidgets();
    });
  }

  // --- User Widget Order Management ---
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

  // --- UI Build Methods (Dialogs, Layouts, etc.) ---
  // No changes needed below this line. The following methods are correct.

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
                          // FIXED: Moved the save call inside setState for reliability.
                          setState(() {
                            _userWidgetOrder.add(widgetModel.id);
                            _saveUserWidgetOrder();
                          });
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
                // FIXED: Moved the save call inside setState for reliability.
                setState(() {
                  _userWidgetOrder.remove(widgetIdToRemove);
                  _saveUserWidgetOrder();
                });
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

  Widget _buildWidgetTile(BuildContext context, String widgetId) {
    final theme = Theme.of(context);
    final model = _availableWidgets[widgetId];

    if (model == null) {
      return const SizedBox.shrink();
    }

    final widgetContent = Theme(
      data: theme.copyWith(
        cardTheme: theme.cardTheme.copyWith(
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(),
        ),
      ),
      child: model.builder(context),
    );

    return Stack(
      key: ValueKey(widgetId),
      clipBehavior: Clip.none,
      children: [
        widgetContent,
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

  Widget _buildSingleColumnLayout(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: _userWidgetOrder.length,
      onReorder: (int oldIndex, int newIndex) {
        // FIXED: Moved the save call inside setState and corrected the reorder logic.
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final String item = _userWidgetOrder.removeAt(oldIndex);
          _userWidgetOrder.insert(newIndex, item);
          _saveUserWidgetOrder();
        });
      },
      itemBuilder: (context, index) {
        final widgetId = _userWidgetOrder[index];
        final isFirst = index == 0;
        final isLast = index == _userWidgetOrder.length - 1;

        final shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(20.0) : const Radius.circular(20.0),
            bottom: isLast ? const Radius.circular(20.0) : const Radius.circular(20.0),
          ),
        );

        final itemContent = Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Material(
            shape: shape,
            clipBehavior: Clip.antiAlias,
            child: _buildWidgetTile(context, widgetId),
          ),
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

  Widget _buildTwoColumnLayout(BuildContext context, BoxConstraints constraints) {
    // Define the shape you want to use consistently.
    // This is the same shape from your single-column layout, but simplified.
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    );

    if (!_isInEditMode) {
      return Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: _userWidgetOrder.map((widgetId) {
          final itemWidth = (constraints.maxWidth / 2) - 4.0;
          return SizedBox(
            width: itemWidth,
            // --- ADD THIS WRAPPER ---
            child: Material(
              shape: cardShape,
              clipBehavior: Clip.antiAlias,
              child: _buildWidgetTile(context, widgetId),
            ),
            // -------------------------
          );
        }).toList(),
      );
    }

    return ReorderableGridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.9, // You may need to adjust this after adding corners
      ),
      itemCount: _userWidgetOrder.length,
      itemBuilder: (context, index) {
        final widgetId = _userWidgetOrder[index];
        return SizedBox( // The SizedBox key is fine, but the child needs the wrapper
          key: ValueKey(widgetId),
          // --- ADD THIS WRAPPER ---
          child: Material(
            shape: cardShape,
            clipBehavior: Clip.antiAlias,
            child: _buildWidgetTile(context, widgetId),
          ),
          // -------------------------
        );
      },
      onReorder: (int oldIndex, int newIndex) {
        // FIXED: Moved the save call inside setState.
        setState(() {
          final String item = _userWidgetOrder.removeAt(oldIndex);
          _userWidgetOrder.insert(newIndex, item);
          _saveUserWidgetOrder();
        });
      },
    );
  }

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

    // Show a loading indicator while the dashboard is being initialized.
    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
                        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
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
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
                      child: FilledButton.tonal(
                        onPressed: () => setState(() => _isInEditMode = !_isInEditMode),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                        child: Text(_isInEditMode ? 'Done Editing' : 'Edit Widgets'),
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
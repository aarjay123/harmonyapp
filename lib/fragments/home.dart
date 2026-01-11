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
import '../widgets/countdown_card.dart';
import '../widgets/todo_list_card.dart';
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
  bool _isLoading = true;

  static const double _contentMaxWidth = 1200.0;
  static const double _twoColumnBreakpoint = 768.0;

  List<String> _userWidgetOrder = [];
  List<CountdownEvent> _allCountdownEvents = [];
  late Map<String, DashboardWidgetModel> _availableWidgets;

  // Cached SharedPreferences instance
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    _updateGreetingAndDate();

    _prefs = await SharedPreferences.getInstance();
    final eventsString = _prefs?.getString('countdownEventsList');
    final savedOrder = _prefs?.getStringList('userWidgetOrder');

    if (eventsString != null) {
      try {
        final List<dynamic> eventsJson = json.decode(eventsString);
        _allCountdownEvents = eventsJson.map((json) => CountdownEvent.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Error loading events: $e');
      }
    }

    _buildAvailableWidgets();

    List<String> finalOrder;
    if (savedOrder == null) {
      finalOrder = _availableWidgets.keys.toList();
    } else {
      finalOrder = savedOrder.where((id) => _availableWidgets.containsKey(id)).toList();
    }

    if (mounted) {
      setState(() {
        _userWidgetOrder = finalOrder;
        _isLoading = false;
      });
    }
  }

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

  void _updateEvents(List<CountdownEvent> updatedEvents) {
    setState(() {
      _allCountdownEvents = updatedEvents;
      _buildAvailableWidgets();
    });
  }

  Future<void> _saveUserWidgetOrder() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
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
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        final List<DashboardWidgetModel> widgetsToAdd = _availableWidgets.values
            .where((model) => !_userWidgetOrder.contains(model.id))
            .toList();

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            if (widgetsToAdd.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 64, color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'All widgets added',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your dashboard is fully populated.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, left: 8.0),
                  child: Text("Add Widgets", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ),
                ...widgetsToAdd.map((widgetModel) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest,
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(widgetModel.displayName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      trailing: FilledButton.tonalIcon(
                        onPressed: () {
                          setState(() {
                            _userWidgetOrder.add(widgetModel.id);
                            _saveUserWidgetOrder();
                          });
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text("Add"),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  void _showRemoveWidgetDialog(String widgetIdToRemove, String displayName) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Remove Widget'),
          content: Text('Remove "$displayName" from your dashboard?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _userWidgetOrder.remove(widgetIdToRemove);
                  _saveUserWidgetOrder();
                });
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  // --- Layout Builders ---

  /// Builds a single widget tile.
  /// [index] is required only for List View dragging to work on the handle specifically.
  Widget _buildWidgetTile(BuildContext context, String widgetId, {int? index}) {
    final model = _availableWidgets[widgetId];
    if (model == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isEditing = _isInEditMode;

    // The actual widget content
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Theme(
        data: theme.copyWith(
          cardTheme: theme.cardTheme.copyWith(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
          ),
        ),
        child: model.builder(context),
      ),
    );

    if (isEditing) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Dim the widget content and prevent interaction with it
          Opacity(
            opacity: 0.6,
            child: AbsorbPointer(
              absorbing: true,
              child: content,
            ),
          ),

          // 2. Drag Handle (Center)
          // We wrap this specific visual in the drag listener if an index is provided (List View).
          Positioned.fill(
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Builder(
                  builder: (context) {
                    final icon = Icon(
                      Icons.drag_indicator_rounded, 
                      color: theme.colorScheme.onSurface,
                      size: 32,
                    );
                    
                    // If we are in the list view (index provided), make THIS specific button draggable.
                    if (index != null) {
                      return ReorderableDragStartListener(
                        index: index,
                        child: icon,
                      );
                    }
                    // For grid view, the library handles long press on the container.
                    return icon;
                  }
                ),
              ),
            ),
          ),

          // 3. Remove Button (Top Right)
          // MOVED TO END of children list so it sits ON TOP of everything else.
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: () => _showRemoveWidgetDialog(model.id, model.displayName),
              child: Container(
                decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.surface, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)
                    ]
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.close_rounded, size: 20, color: theme.colorScheme.onError),
              ),
            ),
          ),
        ],
      );
    }

    return content;
  }

  Widget _buildSingleColumnLayout(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false, // We provide custom handles
      itemCount: _userWidgetOrder.length,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final String item = _userWidgetOrder.removeAt(oldIndex);
          _userWidgetOrder.insert(newIndex, item);
          _saveUserWidgetOrder();
        });
      },
      itemBuilder: (context, index) {
        final widgetId = _userWidgetOrder[index];
        // Pass index to enable specific drag handle
        return Padding(
          key: ValueKey(widgetId),
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildWidgetTile(context, widgetId, index: index),
        );
      },
    );
  }

  Widget _buildTwoColumnLayout(BuildContext context, BoxConstraints constraints) {
    if (!_isInEditMode) {
      return Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: _userWidgetOrder.map((widgetId) {
          final itemWidth = (constraints.maxWidth / 2) - 6.0;
          return SizedBox(
            key: ValueKey(widgetId),
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
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.85,
      ),
      itemCount: _userWidgetOrder.length,
      itemBuilder: (context, index) {
        final widgetId = _userWidgetOrder[index];
        // Note: ReorderableGridView usually relies on LongPress on the item itself.
        // We don't pass 'index' here to _buildWidgetTile because ReorderableGridView
        // handles the listeners internally differently than ListView.
        return Container(
          key: ValueKey(widgetId),
          child: _buildWidgetTile(context, widgetId),
        );
      },
      onReorder: (int oldIndex, int newIndex) {
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.dashboard_customize_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Design Your Dashboard',
              style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the edit button in the top right to add widgets and customize your home.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: _isInEditMode
          ? FloatingActionButton.extended(
        onPressed: _showAddWidgetDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text("Add Widget"),
      )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _updateGreetingAndDate());
        },
        edgeOffset: 100,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // --- Modern Sliver Header ---
            SliverAppBar.large(
              expandedHeight: 160,
              backgroundColor: colorScheme.surface,
              pinned: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Icon(
                      _isInEditMode ? Icons.check_rounded : Icons.edit_rounded,
                      color: _isInEditMode ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                    tooltip: _isInEditMode ? 'Finish Editing' : 'Customize Dashboard',
                    style: IconButton.styleFrom(
                      backgroundColor: _isInEditMode ? colorScheme.primaryContainer : null,
                    ),
                    onPressed: () => setState(() => _isInEditMode = !_isInEditMode),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                // WRAPPED TITLE IN FITTEDBOX TO PREVENT OVERFLOW
                title: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isInEditMode ? 'Edit Layout' : _greeting,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      if (!_isInEditMode)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 14, color: colorScheme.primary),
                              const SizedBox(width: 6),
                              Text(
                                _formattedDate,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Gradient removed (defaults to surface color)
              ),
            ),

            // --- Widget Content ---
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
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
          ],
        ),
      ),
    );
  }
}
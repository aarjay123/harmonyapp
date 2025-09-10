import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

/// Model for a single countdown event.
class CountdownEvent {
  final String id;
  String name;
  DateTime targetDate;

  CountdownEvent({required this.id, required this.name, required this.targetDate});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetDate': targetDate.toIso8601String(),
  };

  factory CountdownEvent.fromJson(Map<String, dynamic> json) {
    return CountdownEvent(
      id: json['id'],
      name: json['name'],
      targetDate: DateTime.parse(json['targetDate']),
    );
  }
}

/// A card widget that displays multiple countdowns and reports changes.
class CountdownCard extends StatefulWidget {
  // NEW: A callback function to notify the parent widget of any changes.
  final Function(List<CountdownEvent>) onEventsUpdated;

  const CountdownCard({super.key, required this.onEventsUpdated});

  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard> {
  List<CountdownEvent> _events = [];
  Timer? _timer;
  final TextEditingController _eventNameController = TextEditingController();

  static const String _eventsKey = 'countdownEventsList';

  @override
  void initState() {
    super.initState();
    _loadEvents(); // The widget still loads its own initial state.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _eventNameController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsString = prefs.getString(_eventsKey);
    if (eventsString != null && mounted) {
      final List<dynamic> eventsJson = json.decode(eventsString);
      setState(() {
        _events = eventsJson.map((json) => CountdownEvent.fromJson(json)).toList();
      });
      // Optionally notify parent on initial load, though parent also loads.
      // widget.onEventsUpdated(_events);
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String eventsString = json.encode(_events.map((event) => event.toJson()).toList());
    await prefs.setString(_eventsKey, eventsString);
    // IMPORTANT: Call the callback to notify the parent widget of the change.
    widget.onEventsUpdated(_events);
  }

  void _addEvent(String name, DateTime date) {
    final newEvent = CountdownEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      targetDate: date,
    );
    setState(() {
      _events.add(newEvent);
    });
    _saveEvents(); // This will now also call the onEventsUpdated callback.
  }

  void _deleteEvent(String id) {
    setState(() {
      _events.removeWhere((event) => event.id == id);
    });
    _saveEvents(); // This will now also call the onEventsUpdated callback.
  }

  String _getCountdownText(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now);

    if (difference.isNegative) {
      return 'Event has passed!';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    return '$days d : $hours h : $minutes m';
  }

  Future<void> _showAddEventDialog() async {
    _eventNameController.clear();
    DateTime? selectedDate;

    final newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );

    if (newDate == null) return;
    selectedDate = newDate;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: const Text('Add New Countdown'),
        content: TextField(
          controller: _eventNameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g., Holiday Trip'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final eventName = _eventNameController.text.trim();
              if (eventName.isNotEmpty && selectedDate != null) {
                _addEvent(eventName, selectedDate!);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(CountdownEvent event) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: const Text('Delete Countdown'),
        content: Text('Are you sure you want to delete the countdown for "${event.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              _deleteEvent(event.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Countdowns',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline_rounded, color: colorScheme.primary),
                  onPressed: _showAddEventDialog,
                  tooltip: 'Add Countdown',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(
                    'No countdowns yet. Add one!',
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error, size: 20),
                              onPressed: () => _showDeleteConfirmationDialog(event),
                              tooltip: 'Delete Countdown',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCountdownText(event.targetDate),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// IMPORTANT: You must import your CountdownEvent model from the other file.
// Adjust the import path as necessary for your project structure.
import './countdown_card.dart'; // Assuming countdown_card.dart is in the same folder.

/// A card widget that displays a monthly calendar integrated with countdown events.
class CalendarCard extends StatefulWidget {
  // The calendar now accepts a list of events to display.
  final List<CountdownEvent> events;

  const CalendarCard({super.key, required this.events});

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late List<CountdownEvent> _selectedDayEvents;

  @override
  void initState() {
    super.initState();
    _selectedDayEvents = _getEventsForDay(_selectedDay);
  }

  /// A helper method to get all events for a specific day.
  List<CountdownEvent> _getEventsForDay(DateTime day) {
    // This will return a list of events where the event's targetDate is the same day as the 'day' parameter.
    // It ignores the time part of the DateTime object for comparison.
    return widget.events.where((event) {
      return event.targetDate.year == day.year &&
          event.targetDate.month == day.month &&
          event.targetDate.day == day.day;
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedDayEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  // Helper function to check if two DateTime objects represent the same day.
  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, colorScheme),
            const SizedBox(height: 16),
            _buildCalendarGrid(theme, colorScheme),
            const SizedBox(height: 12),
            Divider(color: colorScheme.onSurfaceVariant.withOpacity(0.2)),
            const SizedBox(height: 12),
            _buildEventList(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  /// Builds the header with the title and month navigation.
  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(Icons.calendar_month_rounded, color: colorScheme.onSurfaceVariant, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            DateFormat('MMMM y').format(_focusedDay), // e.g., "August 2025"
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: colorScheme.onSurfaceVariant),
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
            });
          },
        ),
      ],
    );
  }

  /// Builds the main calendar grid with days and event markers.
  Widget _buildCalendarGrid(ThemeData theme, ColorScheme colorScheme) {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    // Adjust weekday to be 0 for Monday, 6 for Sunday
    final startWeekday = (firstDayOfMonth.weekday == 7) ? 0 : firstDayOfMonth.weekday - 1;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            return Expanded(
              child: Text(
                dayNames[index],
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemCount: daysInMonth + startWeekday,
          itemBuilder: (context, index) {
            if (index < startWeekday) {
              return const SizedBox.shrink(); // Empty cell before the 1st day
            }

            final dayNumber = index - startWeekday + 1;
            final day = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
            final eventsOnDay = _getEventsForDay(day);
            final isSelected = isSameDay(_selectedDay, day);
            final isToday = isSameDay(DateTime.now(), day);

            return GestureDetector(
              onTap: () => _onDaySelected(day, _focusedDay),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : null,
                  borderRadius: BorderRadius.circular(8.0),
                  border: isToday && !isSelected ? Border.all(color: colorScheme.primary) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$dayNumber',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    // Event marker dot
                    if (eventsOnDay.isNotEmpty)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? colorScheme.onPrimary : colorScheme.tertiary,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Builds the list of events for the currently selected day.
  Widget _buildEventList(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Events on ${DateFormat.yMMMd().format(_selectedDay)}",
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedDayEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "No events scheduled.",
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.8)),
            ),
          )
        else
          ..._selectedDayEvents.map((event) => ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(Icons.circle, color: colorScheme.tertiary, size: 12),
            title: Text(
              event.name,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          )),
      ],
    );
  }
}

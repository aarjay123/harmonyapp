import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:url_launcher/url_launcher.dart'; // For opening URLs

/// A card widget that displays a simple monthly calendar with navigation.
class CalendarCard extends StatefulWidget {
  const CalendarCard({super.key});

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  DateTime _focusedDay = DateTime.now(); // Represents the month currently displayed in the calendar
  DateTime _selectedDay = DateTime.now(); // Represents the specific day selected by the user

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0, // Flat card design
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.surfaceVariant, // Uses surface variant color for distinct look
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Consistent internal padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row for the Calendar card
            Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: colorScheme.onSurfaceVariant, size: 28),
                const SizedBox(width: 12),
                Text(
                  "My Calendar",
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600
                  ),
                ),
                const Spacer(), // Pushes navigation buttons to the end
                // Left arrow button for previous month
                IconButton(
                  icon: Icon(Icons.chevron_left_rounded, color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    setState(() {
                      // Navigate to the first day of the previous month
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                      _selectedDay = _focusedDay; // Reset selected day to start of new month
                    });
                  },
                ),
                // Right arrow button for next month
                IconButton(
                  icon: Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    setState(() {
                      // Navigate to the first day of the next month
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                      _selectedDay = _focusedDay; // Reset selected day to start of new month
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16), // Space below header

            // Display current month and year (e.g., "June 2024")
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                DateFormat('MMMM y').format(_focusedDay), // Formats to "Month Year"
                style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            // Header row for days of the week (Mon, Tue, etc.)
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
                        fontWeight: FontWeight.bold
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8), // Space below day names

            // Grid for calendar days
            GridView.builder(
              shrinkWrap: true, // Takes only the space it needs
              physics: const NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // 7 columns for days of the week
                childAspectRatio: 1.0, // Make each day cell square
                mainAxisSpacing: 4.0, // Vertical spacing between day cells
                crossAxisSpacing: 4.0, // Horizontal spacing between day cells
              ),
              // Calculate the total number of cells needed for the month, including leading empty cells
              itemCount: DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day + // Total days in current month
                  (DateTime(_focusedDay.year, _focusedDay.month, 1).weekday - 1), // Number of empty cells before the 1st day
              itemBuilder: (context, index) {
                final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
                // Adjusting weekday to be 0 for Monday, 6 for Sunday for 0-indexed list for easier calculation
                final weekdayOfFirstDay = (firstDayOfMonth.weekday == 7) ? 0 : firstDayOfMonth.weekday;

                // Calculate the actual day number for the current cell
                final dayNumber = index - weekdayOfFirstDay + 1;

                // Check if the calculated day number falls within the current month
                final isCurrentMonthDay = dayNumber > 0 && dayNumber <= DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;

                // Create a DateTime object for the day in question
                final dayInQuestion = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);

                // Check if this day is the currently selected day
                final isSelectedDay = isCurrentMonthDay &&
                    _selectedDay.year == dayInQuestion.year &&
                    _selectedDay.month == dayInQuestion.month &&
                    _selectedDay.day == dayInQuestion.day;

                // Check if this day is today's date
                final isToday = dayInQuestion.year == DateTime.now().year &&
                    dayInQuestion.month == DateTime.now().month &&
                    dayInQuestion.day == DateTime.now().day;

                return GestureDetector(
                  onTap: isCurrentMonthDay // Only tappable if it's a valid day in the current month
                      ? () {
                    setState(() {
                      _selectedDay = dayInQuestion; // Update the selected day
                    });
                    print('Selected day: $_selectedDay'); // Debugging print
                  }
                      : null,
                  child: Container(
                    alignment: Alignment.center, // Center the day number text
                    decoration: BoxDecoration(
                      color: isSelectedDay
                          ? colorScheme.primary // Highlight color for selected day
                          : (isToday ? colorScheme.primary.withOpacity(0.2) : Colors.transparent), // Subtle highlight for today
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners for day cells
                      border: isToday && !isSelectedDay ? Border.all(color: colorScheme.primary, width: 1.0) : null, // Border for today if not selected
                    ),
                    child: Text(
                      isCurrentMonthDay ? '$dayNumber' : '', // Display day number only if it's a valid day
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelectedDay
                            ? colorScheme.onPrimary // Text color for selected day
                            : (isCurrentMonthDay
                            ? colorScheme.onSurfaceVariant // Text color for other days in current month
                            : colorScheme.onSurfaceVariant.withOpacity(0.4)), // Faded text for empty cells
                        fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.normal, // Bold for selected day
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16), // Space before "View Full Calendar" button

            // "View Full Calendar" button
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: () async {
                  final Uri calendarUrl = Uri.parse('https://calendar.google.com'); // Google Calendar URL
                  if (await canLaunchUrl(calendarUrl)) {
                    await launchUrl(calendarUrl, mode: LaunchMode.externalApplication); // Opens in external browser
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open calendar website.')),
                    );
                  }
                },
                child: const Text("View Full Calendar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

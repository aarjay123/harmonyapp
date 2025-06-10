// home.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:geolocator/geolocator.dart'; // For getting user location
import 'package:http/http.dart' as http; // For making API requests
import 'dart:convert'; // For decoding JSON
import 'dart:async'; // For TimeoutException
import 'package:url_launcher/url_launcher.dart'; // For opening news article URLs
import 'package:shared_preferences/shared_preferences.dart'; // For local data persistence

// IMPORTANT: Add 'url_launcher: ^6.2.2' and 'shared_preferences: ^2.2.0' to your pubspec.yaml under dependencies:
// Example pubspec.yaml:
/*
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.1
  intl: ^0.19.0
  geolocator: ^11.0.0
  url_launcher: ^6.2.2
  shared_preferences: ^2.2.0 # Add this line
*/


// Model to hold weather data
class WeatherData {
  final String cityName;
  final double temperature; // Celsius
  final String iconCode;
  final bool isFallback; // To indicate if this is fallback data

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.iconCode,
    this.isFallback = false,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, {bool isFallback = false}) {
    T? _safeGet<T>(Map<String, dynamic> map, List<String> keys, [T? defaultValue]) {
      dynamic current = map;
      for (String key in keys) {
        if (current is Map<String, dynamic> && current.containsKey(key)) {
          current = current[key];
        } else {
          return defaultValue;
        }
      }
      return current is T ? current : defaultValue;
    }

    return WeatherData(
      cityName: _safeGet<String>(json, ['name'], 'Unknown City')!,
      temperature: (_safeGet<num>(json, ['main', 'temp'], 273.15)!.toDouble() - 273.15),
      iconCode: _safeGet<String>(json, ['weather', '0', 'icon'], '01d')!,
      isFallback: isFallback,
    );
  }
}

// NewsFeedCard Widget - Fetches and displays real-time news
class NewsFeedCard extends StatefulWidget {
  const NewsFeedCard({super.key});

  @override
  State<NewsFeedCard> createState() => _NewsFeedCardState();
}

class _NewsFeedCardState extends State<NewsFeedCard> {
  List<Map<String, String>> _newsArticles = [];
  bool _isLoadingNews = true;
  String? _newsError;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  // Fetches news articles from NewsAPI.org
  Future<void> _fetchNews() async {
    if (!mounted) return;
    setState(() {
      _isLoadingNews = true;
      _newsError = null;
    });

    // --- IMPORTANT: Replace 'YOUR_ACTUAL_NEWS_API_KEY_HERE' with your actual API key from NewsAPI.org ---
    // The key you provided previously was '060f8eb17f9345b59475d62a5fcac3db'.
    // Please ensure it is active and has requests remaining on NewsAPI.org dashboard.
    const String newsApiKey = '060f8eb17f9345b59475d62a5fcac3db'; // Use your actual key here

    // --- MODIFIED: Changed country from 'gb' to 'us' for testing ---
    // NewsAPI.org's free tier often has more "top headlines" for the US.
    // You can try 'gb' again or other countries once you confirm it works with 'us'.
    final Uri uri = Uri.parse('https://newsapi.org/v2/top-headlines?sources=bbc-news&pageSize=10&apiKey=$newsApiKey'); // Added pageSize=10

    // Check if API key is empty or still the placeholder
    if (newsApiKey == 'YOUR_ACTUAL_NEWS_API_KEY_HERE' || newsApiKey.isEmpty) {
      if (mounted) {
        setState(() {
          _newsError = 'News API key not configured. Please get one from newsapi.org.';
          _isLoadingNews = false;
        });
      }
      return;
    }

    print('News API URL: $uri'); // Debugging: Print the URL being called

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted) return;

      print('News API Response Status: ${response.statusCode}'); // Debugging: Print status code

      if (response.statusCode == 200) {
        print('News API Response Body (Success): ${response.body}'); // Debugging: Print full response body on success
        final decodedJson = json.decode(response.body);
        List<Map<String, String>> fetchedArticles = [];
        // Safely access 'articles' array
        if (decodedJson['articles'] != null && decodedJson['articles'] is List) {
          for (var article in decodedJson['articles']) {
            fetchedArticles.add({
              'title': article['title'] ?? 'No title',
              'content': article['description'] ?? 'No description',
              'url': article['url'] ?? '',
            });
          }
        }
        setState(() {
          _newsArticles = fetchedArticles.take(3).toList(); // Take top 3 for brevity
          _isLoadingNews = false;
          if (_newsArticles.isEmpty) {
            _newsError = 'No news available at the moment, or API returned no articles for this query.';
          } else {
            _newsError = null; // Clear any previous errors if articles are found
          }
        });
      } else {
        print('News API Error Body: ${response.body}'); // Debugging: Print error body for non-200 status
        setState(() {
          // Provide more specific error message based on status code if possible
          String errorMessage = 'Failed to load news (Error: ${response.statusCode}).';
          if (response.statusCode == 401) {
            errorMessage += ' Check if your News API key is valid or activated.';
          } else if (response.statusCode == 429) {
            errorMessage += ' Too many requests. You might be rate-limited.';
          } else {
            errorMessage += ' Response: ${response.body.substring(0, response.body.length.clamp(0, 200))}...'; // Show part of body
          }
          _newsError = errorMessage;
          _isLoadingNews = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _newsError = 'Failed to fetch news. Check internet connection. Error: $e';
        _isLoadingNews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.newspaper_rounded, color: colorScheme.onTertiaryContainer, size: 28),
                const SizedBox(width: 12),
                Text(
                  "Latest News",
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: colorScheme.onTertiaryContainer.withOpacity(0.7)),
                  onPressed: _fetchNews,
                  tooltip: 'Refresh News',
                )
              ],
            ),
            const SizedBox(height: 16),
            _isLoadingNews
                ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: colorScheme.onTertiaryContainer),
              ),
            )
                : _newsError != null
                ? Text(
              _newsError!,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            )
                : _newsArticles.isEmpty
                ? Text(
              'No news available at the moment.', // This message will now also be shown if API returns no articles.
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onTertiaryContainer.withOpacity(0.7)),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _newsArticles.map((article) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article['title']!,
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article['content']!, // Assuming 'content' for description
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onTertiaryContainer.withOpacity(0.9)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Read More button to open article URL
                    if (article['url']!.isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            final Uri url = Uri.parse(article['url']!);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication); // Opens in external browser
                            } else {
                              // Fallback for when the URL cannot be launched
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not open news link.')),
                              );
                            }
                          },
                          child: Text(
                            'Read More',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              )).toList(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                // MODIFIED: onPressed now opens BBC News website
                onPressed: () async {
                  // Changed from 'const' to 'final' as Uri.parse is not a constant expression.
                  final Uri bbcNewsUrl = Uri.parse('https://www.bbc.co.uk/news');
                  if (await canLaunchUrl(bbcNewsUrl)) {
                    await launchUrl(bbcNewsUrl, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open BBC News website.')),
                    );
                  }
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text("View All News"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// QuickNotesCard Widget
class QuickNotesCard extends StatefulWidget {
  const QuickNotesCard({super.key});

  @override
  State<QuickNotesCard> createState() => _QuickNotesCardState();
}

class _QuickNotesCardState extends State<QuickNotesCard> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _loadNotes(); // MODIFIED: Load saved notes on init
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // MODIFIED: Load notes from SharedPreferences
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notesController = TextEditingController(text: prefs.getString('quickNotes') ?? 'Write your quick notes here...');
    });
  }

  // MODIFIED: Save notes to SharedPreferences
  Future<void> _saveNotes(String notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quickNotes', notes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.primaryContainer, // Can choose a different color scheme if desired
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              keyboardType: TextInputType.multiline,
              maxLines: null, // Allows unlimited lines
              minLines: 3, // Minimum 3 lines visible
              decoration: InputDecoration(
                hintText: 'Type your notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none, // No border for a cleaner look
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant, // Background for the text field
                contentPadding: const EdgeInsets.all(12.0),
              ),
              style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              cursorColor: colorScheme.primary,
              onChanged: _saveNotes, // MODIFIED: Save notes as they change
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  _notesController.clear();
                  _saveNotes(''); // MODIFIED: Clear saved notes
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

// CalendarCard Widget - Displays a simple monthly calendar
class CalendarCard extends StatefulWidget {
  const CalendarCard({super.key});

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  DateTime _focusedDay = DateTime.now(); // The month currently displayed
  DateTime _selectedDay = DateTime.now(); // The specific day selected

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.surfaceVariant, // Choose a suitable color for the card
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                const Spacer(),
                // Navigation buttons for month
                IconButton(
                  icon: Icon(Icons.chevron_left_rounded, color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                      _selectedDay = _focusedDay; // Reset selected day to start of new month
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                      _selectedDay = _focusedDay; // Reset selected day to start of new month
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Display Current Month and Year
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                DateFormat('MMMM y').format(_focusedDay),
                style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            // Days of the week header
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
            const SizedBox(height: 8),
            // Calendar Grid
            // This calculates the correct number of cells needed, including leading empty cells for the first day of the month.
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Important for nested scrolling
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),
              itemCount: DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day + // Days in current month
                  (DateTime(_focusedDay.year, _focusedDay.month, 1).weekday - 1), // Leading empty cells
              itemBuilder: (context, index) {
                final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
                // Adjusting weekday to be 0 for Monday, 6 for Sunday for 0-indexed list
                final weekdayOfFirstDay = (firstDayOfMonth.weekday == 7) ? 0 : firstDayOfMonth.weekday;

                final dayNumber = index - weekdayOfFirstDay + 1; // +1 to convert from 0-indexed to 1-indexed day

                final isCurrentMonthDay = dayNumber > 0 && dayNumber <= DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;

                final dayInQuestion = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);

                final isSelectedDay = isCurrentMonthDay &&
                    _selectedDay.year == dayInQuestion.year &&
                    _selectedDay.month == dayInQuestion.month &&
                    _selectedDay.day == dayInQuestion.day;

                final isToday = dayInQuestion.year == DateTime.now().year &&
                    dayInQuestion.month == DateTime.now().month &&
                    dayInQuestion.day == DateTime.now().day;

                return GestureDetector(
                  onTap: isCurrentMonthDay
                      ? () {
                    setState(() {
                      _selectedDay = dayInQuestion;
                    });
                    // You can add an action here, e.g., show events for the selected day
                    print('Selected day: $_selectedDay');
                  }
                      : null,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelectedDay
                          ? colorScheme.primary // Selected day color
                          : (isToday ? colorScheme.primary.withOpacity(0.2) : Colors.transparent), // Today's color
                      borderRadius: BorderRadius.circular(8.0),
                      border: isToday && !isSelectedDay ? Border.all(color: colorScheme.primary, width: 1.0) : null, // Border for today if not selected
                    ),
                    child: Text(
                      isCurrentMonthDay ? '$dayNumber' : '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelectedDay
                            ? colorScheme.onPrimary // Text color for selected day
                            : (isCurrentMonthDay
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurfaceVariant.withOpacity(0.4)), // Text color for other days
                        fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: () async {
                  // Changed from 'const' to 'final' as Uri.parse is not a constant expression.
                  final Uri calendarUrl = Uri.parse('https://calendar.google.com');
                  if (await canLaunchUrl(calendarUrl)) {
                    await launchUrl(calendarUrl, mode: LaunchMode.externalApplication);
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

// QuickLinksCard Widget
class QuickLinksCard extends StatefulWidget {
  const QuickLinksCard({super.key});

  @override
  State<QuickLinksCard> createState() => _QuickLinksCardState();
}

class _QuickLinksCardState extends State<QuickLinksCard> {
  // Use a mutable list for links, to allow adding/removing
  List<Map<String, String>> _links = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLinks(); // MODIFIED: Load saved links on init
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  // MODIFIED: Load links from SharedPreferences
  Future<void> _loadLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? linksJson = prefs.getString('quickLinks');
    if (linksJson != null && linksJson.isNotEmpty) {
      final List<dynamic> decoded = json.decode(linksJson);
      setState(() {
        _links = decoded.map((item) => Map<String, String>.from(item)).toList();
      });
    }
  }

  // MODIFIED: Save links to SharedPreferences
  Future<void> _saveLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final String linksJson = json.encode(_links);
    await prefs.setString('quickLinks', linksJson);
  }

  void _addLink() {
    if (_titleController.text.isNotEmpty && _urlController.text.isNotEmpty) {
      // Basic URL validation
      // MODIFIED: Added null check and default for hasScheme
      if (!(Uri.tryParse(_urlController.text)?.hasScheme ?? false)) {
        // Prepend https:// if no scheme is provided or if parsing failed
        _urlController.text = 'https://${_urlController.text}';
      }

      setState(() {
        _links.add({
          'title': _titleController.text,
          'url': _urlController.text,
        });
      });
      _saveLinks(); // Save after adding
      _titleController.clear();
      _urlController.clear();
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  void _removeLink(int index) {
    setState(() {
      _links.removeAt(index);
    });
    _saveLinks(); // Save after removing
  }

  void _showAddLinkDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          backgroundColor: colorScheme.surfaceContainerHigh,
          title: Text('Add New Link', style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Link Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'URL (e.g., https://example.com)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                keyboardType: TextInputType.url,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
            ),
            FilledButton(
              onPressed: _addLink,
              child: const Text('Add'),
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link_rounded, color: colorScheme.onSurfaceVariant, size: 28),
                const SizedBox(width: 12),
                Text(
                  "Quick Links",
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.add_circle_outline_rounded, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                  onPressed: () => _showAddLinkDialog(context),
                  tooltip: 'Add New Link',
                )
              ],
            ),
            const SizedBox(height: 16),
            _links.isEmpty
                ? Text(
              'No quick links added yet. Tap + to add one!',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_links.length, (index) {
                final link = _links[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () async {
                      final Uri url = Uri.parse(link['url']!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not open link: ${link['url']}')),
                        );
                      }
                    },
                    onLongPress: () {
                      // Option to remove link on long press
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                          backgroundColor: colorScheme.surfaceContainerHigh,
                          title: Text('Remove Link', style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface)),
                          content: Text('Do you want to remove "${link['title']}"?', style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
                            ),
                            FilledButton(
                              onPressed: () {
                                _removeLink(index);
                                Navigator.of(dialogContext).pop();
                              },
                              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.link, size: 20, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              link['title']!,
                              style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.open_in_new_rounded, size: 18, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// NEW WIDGET: Daily Affirmation/Quote Card
class DailyAffirmationCard extends StatefulWidget {
  const DailyAffirmationCard({super.key});

  @override
  State<DailyAffirmationCard> createState() => _DailyAffirmationCardState();
}

class _DailyAffirmationCardState extends State<DailyAffirmationCard> {
  List<String> _affirmations = [
    "I am capable of achieving my goals.",
    "Every day is a new opportunity to grow and improve.",
    "I am surrounded by positivity and abundance.",
    "My potential is limitless.",
    "I choose joy and happiness today.",
    "I am grateful for all the good in my life.",
    "I trust my intuition and make wise decisions.",
    "I am strong, resilient, and brave.",
    "Challenges help me discover my inner strength.",
    "I radiate love and compassion.",
  ];
  String _currentAffirmation = "";
  int _currentAffirmationIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAffirmationIndex(); // MODIFIED: Load saved index
  }

  // MODIFIED: Load the last displayed affirmation index
  Future<void> _loadAffirmationIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentAffirmationIndex = prefs.getInt('dailyAffirmationIndex') ?? 0;
      _currentAffirmation = _affirmations[_currentAffirmationIndex];
    });
  }

  // MODIFIED: Save the current affirmation index
  Future<void> _saveAffirmationIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyAffirmationIndex', index);
  }

  void _getNewAffirmation() {
    setState(() {
      _currentAffirmationIndex = (_currentAffirmationIndex + 1) % _affirmations.length;
      _currentAffirmation = _affirmations[_currentAffirmationIndex];
      _saveAffirmationIndex(_currentAffirmationIndex); // Save the new index
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.secondaryContainer, // A different color to differentiate
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star_half_rounded, color: colorScheme.onSecondaryContainer, size: 28),
                const SizedBox(width: 12),
                Text(
                  "Daily Affirmation",
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7)),
                  onPressed: _getNewAffirmation,
                  tooltip: 'New Affirmation',
                )
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _currentAffirmation,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// NativeWelcomePage Widget - The main home page
class NativeWelcomePage extends StatefulWidget {
  final Function(int) onNavigateToTab;
  const NativeWelcomePage({super.key, required this.onNavigateToTab});

  @override
  State<NativeWelcomePage> createState() => _NativeWelcomePageState();
}

class _NativeWelcomePageState extends State<NativeWelcomePage> {
  String _greeting = '';
  String _formattedDate = '';
  WeatherData? _weatherData;
  bool _isLoadingWeather = true;
  String? _weatherError;
  bool _isInEditMode = false; // State variable for edit mode

  // OpenWeatherMap API key (replace with your own)
  // The key 'b9c22dc18482e0924657dbf0ea281d35' is now treated as a valid input.
  // If this is still giving an error, please ensure it's your actual OpenWeatherMap key
  // and that it's activated on their website (can take a few hours).
  final String _apiKey = 'b9c22dc18482e0924657dbf0ea281d35';
  static const double _carnforthLat = 54.1300;
  static const double _carnforthLon = -2.7700;

  // Max width for the main content area on larger screens
  static const double _contentMaxWidth = 768.0;

  // List to store and manage the order of widget IDs
  // In a real app, this would be loaded from persistence (e.g., Firestore/SharedPreferences)
  List<String> _userWidgetOrder = ['weather_card', 'quick_actions', 'news_feed', 'quick_notes', 'calendar_card', 'quick_links', 'daily_affirmation']; // MODIFIED: Removed 'upcoming_events'

  // Map to associate widget IDs with their respective builders
  late final Map<String, Widget Function(BuildContext)> _availableWidgets;

  @override
  void initState() {
    super.initState();
    _updateGreetingAndDate();
    _fetchWeatherData();
    _loadUserWidgetOrder(); // MODIFIED: Load saved order

    // Initialize available widgets map
    _availableWidgets = {
      'weather_card': (context) => Card( // This is the 'At a Glance' card with Weather and Date
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  'At a Glance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              _buildInfoRow(
                context: context,
                icon: Icons.thermostat_rounded,
                title: 'Weather',
                contentWidget: _buildWeatherContent(context),
              ),
              Divider(color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.2), height: 1),
              _buildInfoRow(
                context: context,
                icon: Icons.calendar_today_rounded,
                title: 'Date',
                contentWidget: Text(
                  _formattedDate,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
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
      'calendar_card': (context) => const CalendarCard(), // New Calendar widget
      // 'upcoming_events': (context) => const UpcomingEventsCard(), // REMOVED
      'quick_links': (context) => const QuickLinksCard(), // NEW
      'daily_affirmation': (context) => const DailyAffirmationCard(), // NEW
    };
  }

  // MODIFIED: Load the user's widget order from SharedPreferences
  Future<void> _loadUserWidgetOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedOrder = prefs.getStringList('userWidgetOrder');
    if (savedOrder != null && savedOrder.isNotEmpty) {
      setState(() {
        // Filter out any IDs that might not exist in _availableWidgets anymore
        _userWidgetOrder = savedOrder.where((id) => _availableWidgets.containsKey(id)).toList();
        // Add any new default widgets that aren't in the saved list
        for (String defaultId in ['weather_card', 'quick_actions', 'news_feed', 'quick_notes', 'calendar_card', 'quick_links', 'daily_affirmation']) { // MODIFIED: Removed 'upcoming_events' from defaultId list
          if (!_userWidgetOrder.contains(defaultId)) {
            _userWidgetOrder.add(defaultId);
          }
        }
      });
    }
  }

  // MODIFIED: Save the user's widget order to SharedPreferences
  Future<void> _saveUserWidgetOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('userWidgetOrder', _userWidgetOrder);
  }

  // Updates the greeting message based on time of day and current date
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
    _formattedDate = DateFormat('EEEE, d MMMM').format(now);
    if (mounted) setState(() {});
  }

  // Determines the user's current position, falling back to Carnforth if denied or unavailable
  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _weatherError = 'Location services are disabled. Showing weather for Carnforth, UK.');
      return null;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _weatherError = 'Location permission denied. Showing weather for Carnforth, UK.');
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _weatherError = 'Location permission permanently denied. Showing weather for Carnforth, UK.');
      return null;
    }
    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15));
    } on TimeoutException {
      if (mounted) setState(() => _weatherError = 'Could not get current location. Showing weather for Carnforth, UK.');
      return null;
    } catch (e) {
      if (mounted) setState(() => _weatherError = 'Error getting location. Showing weather for Carnforth, UK.');
      return null;
    }
  }

  // Fetches weather data for given coordinates
  Future<void> _fetchWeatherForCoordinates(double lat, double lon, {bool isFallback = false}) async {
    if (!mounted) return;
    if (isFallback || _weatherData == null) {
      setState(() {
        _isLoadingWeather = true;
        if (!isFallback) _weatherError = null;
      });
    }
    final uri = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey');

    print('Weather API URL: $uri'); // Debugging: Print the URL being called

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted) return;

      print('Weather API Response Status: ${response.statusCode}'); // Debugging: Print status code
      if (response.statusCode != 200) {
        print('Weather API Error Body: ${response.body}'); // Debugging: Print error body
      }

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        setState(() {
          _weatherData = WeatherData.fromJson(decodedJson, isFallback: isFallback);
          _isLoadingWeather = false;
          // Only clear error if weather data is successfully fetched and not a fallback scenario that still has an error message
          if (isFallback && (_weatherError == null || !_weatherError!.toLowerCase().contains("location"))) {
            _weatherError = null;
          } else if (!isFallback) { // Clear error if not fallback and successful
            _weatherError = null;
          }
        });
      } else {
        setState(() {
          String errorMessage = 'Failed to load weather (Error: ${response.statusCode}).';
          if (response.statusCode == 401) {
            errorMessage += ' Invalid or inactive API key.';
          } else if (response.statusCode == 429) {
            errorMessage += ' Too many requests.';
          } else {
            errorMessage += ' Response: ${response.body.substring(0, response.body.length.clamp(0, 200))}...';
          }
          _weatherError = errorMessage;
          if (isFallback) _weatherError = 'Failed to load fallback weather: ' + errorMessage;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _weatherError = 'Failed to fetch weather. Check internet connection. Error: $e';
        if (isFallback) _weatherError = 'Failed to fetch fallback weather: ' + _weatherError!;
        _isLoadingWeather = false;
      });
    }
  }

  // Orchestrates fetching weather data, trying user location first, then fallback
  Future<void> _fetchWeatherData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });
    // Check if OpenWeatherMap API key is empty.
    // The previous hardcoded check for 'b9c22dc18482e0924657dbf0ea281d35' has been removed
    // from the explicit "not configured" check here, as it's a user-provided key.
    if (_apiKey.isEmpty) {
      if (mounted) {
        setState(() {
          _weatherError = 'Weather API key is empty. Please set your OpenWeatherMap API key.';
          _isLoadingWeather = false;
        });
      }
      return;
    }
    Position? position = await _determinePosition();
    if (position != null) {
      await _fetchWeatherForCoordinates(position.latitude, position.longitude);
    } else {
      await _fetchWeatherForCoordinates(_carnforthLat, _carnforthLon, isFallback: true);
    }
  }

  // Builds the content for the weather display within the "At a Glance" card
  Widget _buildWeatherContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoadingWeather) {
      return Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: colorScheme.onSecondaryContainer),
          ),
          const SizedBox(width: 16),
          Text(
            'Fetching weather...',
            style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSecondaryContainer),
          ),
        ],
      );
    }
    if (_weatherError != null && _weatherData == null) {
      return ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 28),
        title: Text(_weatherError!, style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.error)),
        trailing: IconButton(
          icon: Icon(Icons.refresh_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7)),
          onPressed: _fetchWeatherData,
          tooltip: 'Retry',
        ),
        dense: true,
        contentPadding: EdgeInsets.zero,
      );
    }
    if (_weatherData != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_weatherError != null) // Display weather error even if fallback data is shown
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _weatherError!,
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSecondaryContainer.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Image.network(
                'https://openweathermap.org/img/wn/${_weatherData!.iconCode}@2x.png',
                width: 48, height: 48,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.cloud_off_rounded, color: colorScheme.onSecondaryContainer, size: 30),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(width: 48, height: 48, child: Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null, color: colorScheme.onSecondaryContainer, strokeWidth: 2.0,)));
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '${_weatherData!.cityName} - ${_weatherData!.temperature.toStringAsFixed(1)}°C',
                  style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7)),
                onPressed: _fetchWeatherData, tooltip: 'Refresh Weather',
              )
            ],
          ),
        ],
      );
    }
    return Text('Weather data processing...', style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSecondaryContainer.withOpacity(0.7)));
  }

  // Helper function to build consistent info rows in the "At a Glance" card
  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget contentWidget,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.onSecondaryContainer, size: 28),
      title: Text(title, style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.w500)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: contentWidget,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
    );
  }

  // Helper function to build quick action cards
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
          padding: const EdgeInsets.symmetric(horizontal:12.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: colorScheme.onPrimaryContainer),
              const SizedBox(height: 12),
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

  // Dialog to allow users to add new widgets
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
        // Filter out widgets already on the page
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
              // Use Expanded to give the ListView space when wrapped in Column with mainAxisSize.min
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true, // Allow ListView to take only as much space as its children
                  itemCount: widgetsToAdd.length,
                  itemBuilder: (context, index) {
                    final widgetId = widgetsToAdd[index];
                    String displayName;
                    // Provide a user-friendly name for each widget ID
                    switch (widgetId) {
                      case 'weather_card': displayName = 'At a Glance (Weather & Date)'; break;;
                      case 'quick_actions': displayName = 'Quick Actions'; break;
                      case 'news_feed': displayName = 'Latest News'; break;
                      case 'quick_notes': displayName = 'Quick Notes'; break;
                      case 'calendar_card': displayName = 'My Calendar'; break; // Added Calendar display name
                    // 'upcoming_events': displayName = 'Upcoming Events'; break; // REMOVED
                      case 'quick_links': displayName = 'Quick Links'; break; // New display name
                      case 'daily_affirmation': displayName = 'Daily Affirmation'; break; // New display name
                      default: displayName = widgetId; // Fallback
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
                            _userWidgetOrder.add(widgetId);
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

  // Method to show a confirmation dialog for removing a widget
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
                  _userWidgetOrder.remove(widgetIdToRemove);
                });
                _saveUserWidgetOrder(); // Save the new order
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

    final Shader greetingGradientShader = LinearGradient(
      colors: <Color>[colorScheme.primary, colorScheme.tertiary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 100.0));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // Pull-to-refresh for weather data
      body: RefreshIndicator(
        onRefresh: _fetchWeatherData,
        color: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: _isInEditMode ? 90.0 : 120.0, // Adjust height based on edit mode
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isInEditMode ? 'Edit Mode' : '$_greeting!',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          foreground: Paint()..shader = greetingGradientShader,
                        ),
                      ),
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
              backgroundColor: colorScheme.surface,
              elevation: 0,
              pinned: false, // Does not stick to the top
              actions: _isInEditMode
                  ? [
                IconButton(
                  icon: Icon(Icons.done_rounded, color: colorScheme.primary),
                  onPressed: () {
                    setState(() {
                      _isInEditMode = false;
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
                      shrinkWrap: true, // Ensures it takes up only needed vertical space
                      physics: const NeverScrollableScrollPhysics(), // Handled by CustomScrollView
                      itemCount: _userWidgetOrder.length,
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final String item = _userWidgetOrder.removeAt(oldIndex);
                          _userWidgetOrder.insert(newIndex, item);
                        });
                        _saveUserWidgetOrder(); // MODIFIED: Save the new order after reorder
                      },
                      itemBuilder: (BuildContext context, int index) {
                        final String widgetId = _userWidgetOrder[index];
                        final Widget? widgetToDisplay = _availableWidgets[widgetId]?.call(context);
                        String displayName;
                        // Determine user-friendly display name for each widget
                        switch (widgetId) {
                          case 'weather_card': displayName = 'At a Glance (Weather & Date)'; break;
                          case 'quick_actions': displayName = 'Quick Actions'; break;
                          case 'news_feed': displayName = 'Latest News'; break;
                          case 'quick_notes': displayName = 'Quick Notes'; break;
                          case 'calendar_card': displayName = 'My Calendar'; break;
                        // case 'upcoming_events': displayName = 'Upcoming Events'; break; // REMOVED
                          case 'quick_links': displayName = 'Quick Links'; break;
                          case 'daily_affirmation': displayName = 'Daily Affirmation'; break;
                          default: displayName = widgetId;
                        }

                        if (widgetToDisplay != null) {
                          Widget itemContent = Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Stack(
                              children: [
                                widgetToDisplay,
                                // Show remove button only in edit mode
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

                          // Enable dragging for reordering only in edit mode
                          if (_isInEditMode) {
                            return ReorderableDelayedDragStartListener(
                              key: ValueKey(widgetId), // Unique key for ReorderableListView
                              index: index,
                              child: itemContent,
                            );
                          } else {
                            // Enable long press to enter edit mode
                            return GestureDetector(
                              key: ValueKey(widgetId), // Unique key for widget identity
                              onLongPress: () {
                                setState(() {
                                  _isInEditMode = true;
                                });
                              },
                              child: itemContent,
                            );
                          }
                        }
                        return const SizedBox.shrink(); // Return empty widget if null
                      },
                    ),
                  ),
                ),
              ),
            ),
            // "Add New Widget" button, shown only in edit mode
            if (_isInEditMode)
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            // Add some padding at the bottom, especially when in edit mode
            SliverToBoxAdapter(
              child: SizedBox(height: _isInEditMode ? 24.0 : 0.0),
            ),
          ],
        ),
      ),
    );
  }
}

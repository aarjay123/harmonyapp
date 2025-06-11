import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making API requests
import 'dart:convert'; // For decoding JSON
import 'dart:async'; // For TimeoutException
import 'package:url_launcher/url_launcher.dart'; // For opening news article URLs

/// A card widget that fetches and displays real-time news headlines.
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
    _fetchNews(); // Fetch news when the widget is initialized
  }

  /// Fetches news articles from NewsAPI.org.
  Future<void> _fetchNews() async {
    if (!mounted) return; // Ensure the widget is still in the widget tree

    setState(() {
      _isLoadingNews = true; // Set loading state
      _newsError = null; // Clear any previous errors
    });

    // --- IMPORTANT: Replace 'YOUR_ACTUAL_NEWS_API_KEY_HERE' with your actual API key from NewsAPI.org ---
    // The key you provided previously was '060f8eb17f9345b59475d62a5fcac3db'.
    // Please ensure it is active and has requests remaining on your NewsAPI.org dashboard.
    const String newsApiKey = '060f8eb17f9345b59475d62a5fcac3db'; // Your NewsAPI.org API Key

    // API endpoint for top headlines from BBC News, with a page size of 10.
    final Uri uri = Uri.parse('https://newsapi.org/v2/top-headlines?sources=bbc-news&pageSize=10&apiKey=$newsApiKey');

    // Basic validation for the API key
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
      // Make the HTTP GET request with a 10-second timeout
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted) return; // Check mount status after async operation

      print('News API Response Status: ${response.statusCode}'); // Debugging: Print HTTP status code

      if (response.statusCode == 200) {
        print('News API Response Body (Success): ${response.body}'); // Debugging: Print full response body
        final decodedJson = json.decode(response.body);
        List<Map<String, String>> fetchedArticles = [];

        // Safely parse the 'articles' array from the JSON response
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
          _newsArticles = fetchedArticles.take(3).toList(); // Take the top 3 articles for display
          _isLoadingNews = false; // Turn off loading indicator
          // Set an error message if no articles were returned, even if the API call was successful
          if (_newsArticles.isEmpty) {
            _newsError = 'No news available at the moment, or API returned no articles for this query.';
          } else {
            _newsError = null; // Clear any previous errors if articles are found
          }
        });
      } else {
        // Handle non-200 HTTP status codes
        print('News API Error Body: ${response.body}'); // Debugging: Print error body for more details
        setState(() {
          String errorMessage = 'Failed to load news (Error: ${response.statusCode}).';
          if (response.statusCode == 401) {
            errorMessage += ' Check if your News API key is valid or activated.';
          } else if (response.statusCode == 429) {
            errorMessage += ' Too many requests. You might be rate-limited.';
          } else {
            errorMessage += ' Response: ${response.body.substring(0, response.body.length.clamp(0, 200))}...'; // Show a snippet of the response body
          }
          _newsError = errorMessage; // Set the error message to be displayed
          _isLoadingNews = false; // Turn off loading indicator
        });
      }
    } catch (e) {
      // Handle network errors (e.g., no internet connection, timeout)
      if (!mounted) return;
      setState(() {
        _newsError = 'Failed to fetch news. Check internet connection. Error: $e'; // Set a generic network error message
        _isLoadingNews = false; // Turn off loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0, // Flat card design
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.tertiaryContainer, // Uses tertiary container color for distinct look
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Consistent internal padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row for the News Feed card
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
                const Spacer(), // Pushes the refresh button to the end
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: colorScheme.onTertiaryContainer.withOpacity(0.7)),
                  onPressed: _fetchNews, // Triggers news refresh
                  tooltip: 'Refresh News',
                )
              ],
            ),
            const SizedBox(height: 16), // Space below header

            // Conditional display based on loading state and errors
            _isLoadingNews
                ? Center(
              // Loading indicator
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: colorScheme.onTertiaryContainer),
              ),
            )
                : _newsError != null // Display error message if an error occurred
                ? Text(
              _newsError!,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            )
                : _newsArticles.isEmpty // Display "No news" message if no articles are found
                ? Text(
              'No news available at the moment.',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onTertiaryContainer.withOpacity(0.7)),
            )
                : Column(
              // Display fetched news articles
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _newsArticles.map((article) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0), // Space between articles
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
                      article['content']!, // Article description/content
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onTertiaryContainer.withOpacity(0.9)),
                      maxLines: 2, // Limit description to 2 lines
                      overflow: TextOverflow.ellipsis, // Add ellipsis if content overflows
                    ),
                    // "Read More" button to open the article URL
                    if (article['url']!.isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            final Uri url = Uri.parse(article['url']!);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication); // Opens in external browser
                            } else {
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
            const SizedBox(height: 8), // Space before "View All News" button
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: () async {
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
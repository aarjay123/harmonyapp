import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:geolocator/geolocator.dart'; // For getting user location
import 'package:http/http.dart' as http; // For making API requests
import 'dart:convert'; // For decoding JSON
import 'dart:async'; // For TimeoutException

// Assuming your project name is 'your_app_name' - adjust this import path if different
import '../models/weather_data.dart'; // Import the WeatherData model

/// A card widget displaying "At a Glance" information including weather and current date.
class AtAGlanceCard extends StatefulWidget {
  final String formattedDate; // Date string passed from the parent (Home Page)
  const AtAGlanceCard({super.key, required this.formattedDate});

  @override
  State<AtAGlanceCard> createState() => _AtAGlanceCardState();
}

class _AtAGlanceCardState extends State<AtAGlanceCard> {
  WeatherData? _weatherData;
  bool _isLoadingWeather = true;
  String? _weatherError;

  // OpenWeatherMap API key (replace with your own actual key)
  final String _apiKey = 'b9c22dc18482e0924657dbf0ea281d35'; // Your OpenWeatherMap API Key
  static const double _carnforthLat = 54.1300; // Fallback latitude for Carnforth, UK
  static const double _carnforthLon = -2.7700; // Fallback longitude for Carnforth, UK

  @override
  void initState() {
    super.initState();
    _fetchWeatherData(); // Initiate weather data fetch on widget initialization
  }

  /// Determines the user's current geographical position.
  /// Falls back to a default location (Carnforth, UK) if location services are
  /// disabled, permissions are denied, or a timeout occurs.
  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled on the device.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() => _weatherError = 'Location services are disabled. Showing weather for Carnforth, UK.');
      }
      return null;
    }

    // Check current location permission status.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission if it's denied.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() => _weatherError = 'Location permission denied. Showing weather for Carnforth, UK.');
        }
        return null;
      }
    }

    // Handle permanently denied permissions.
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() => _weatherError = 'Location permission permanently denied. Showing weather for Carnforth, UK.');
      }
      return null;
    }

    // Attempt to get the current position with a timeout.
    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15));
    } on TimeoutException {
      if (mounted) {
        setState(() => _weatherError = 'Could not get current location. Showing weather for Carnforth, UK.');
      }
      return null;
    } catch (e) {
      // Catch any other errors during location retrieval.
      if (mounted) {
        setState(() => _weatherError = 'Error getting location. Showing weather for Carnforth, UK.');
      }
      return null;
    }
  }

  /// Fetches weather data from OpenWeatherMap API for given latitude and longitude.
  /// [isFallback] indicates if this call is due to a primary location fetch failure.
  Future<void> _fetchWeatherForCoordinates(double lat, double lon, {bool isFallback = false}) async {
    if (!mounted) return; // Ensure widget is still mounted before state updates

    // Show loading state and clear previous errors if not a fallback re-fetch
    if (isFallback || _weatherData == null) {
      setState(() {
        _isLoadingWeather = true;
        if (!isFallback) _weatherError = null;
      });
    }

    // Construct the API URL
    final uri = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey');
    print('Weather API URL: $uri'); // Debugging: Print the URL being called

    try {
      // Make the HTTP GET request with a timeout
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted) return; // Check mount status after async operation

      print('Weather API Response Status: ${response.statusCode}'); // Debugging: Print status code
      if (response.statusCode != 200) {
        print('Weather API Error Body: ${response.body}'); // Debugging: Print error body for non-200 status
      }

      if (response.statusCode == 200) {
        // Decode the JSON response and update weather data
        final decodedJson = json.decode(response.body);
        setState(() {
          _weatherData = WeatherData.fromJson(decodedJson, isFallback: isFallback);
          _isLoadingWeather = false;
          // Clear error if data is successfully fetched
          if (isFallback && (_weatherError == null || !_weatherError!.toLowerCase().contains("location"))) {
            _weatherError = null; // Clear non-location related errors on fallback success
          } else if (!isFallback) { // Clear error if not fallback and successful
            _weatherError = null;
          }
        });
      } else {
        // Handle API errors based on status code
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
          if (isFallback) { // Append fallback context to error message
            _weatherError = 'Failed to load fallback weather: ' + errorMessage;
          }
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      // Handle network or other exceptions
      if (!mounted) return;
      setState(() {
        _weatherError = 'Failed to fetch weather. Check internet connection. Error: $e';
        if (isFallback) { // Append fallback context to error message
          _weatherError = 'Failed to fetch fallback weather: ' + _weatherError!;
        }
        _isLoadingWeather = false;
      });
    }
  }

  /// Orchestrates fetching weather data, trying user's current location first,
  /// then falling back to a default location if the primary attempt fails.
  Future<void> _fetchWeatherData() async {
    if (!mounted) return; // Ensure widget is still mounted

    setState(() {
      _isLoadingWeather = true;
      _weatherError = null; // Clear previous errors
    });

    // Validate API key before making requests
    if (_apiKey.isEmpty || _apiKey == 'YOUR_OPENWEATHERMAP_API_KEY') { // Check for placeholder too
      if (mounted) {
        setState(() {
          _weatherError = 'Weather API key is empty or not configured. Please set your OpenWeatherMap API key.';
          _isLoadingWeather = false;
        });
      }
      return;
    }

    Position? position = await _determinePosition(); // Try to get user's current location
    if (position != null) {
      await _fetchWeatherForCoordinates(position.latitude, position.longitude);
    } else {
      // If user location is not available, use fallback coordinates
      await _fetchWeatherForCoordinates(_carnforthLat, _carnforthLon, isFallback: true);
    }
  }

  /// Builds the content display for the weather section within the card.
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
    // Display error when no weather data could be fetched at all
    if (_weatherError != null && _weatherData == null) {
      return ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 28),
        title: Text(_weatherError!, style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.error)),
        trailing: IconButton(
          icon: Icon(Icons.refresh_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7)),
          onPressed: _fetchWeatherData, // Retry fetching data
          tooltip: 'Retry',
        ),
        dense: true,
        contentPadding: EdgeInsets.zero,
      );
    }
    // Display weather data if available
    if (_weatherData != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display informational error if weather is fallback or partial failure occurred
          if (_weatherError != null)
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
              // Weather icon from OpenWeatherMap
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
              // City name and temperature
              Expanded(
                child: Text(
                  '${_weatherData!.cityName} - ${_weatherData!.temperature.toStringAsFixed(1)}°C',
                  style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Refresh button for weather data
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7)),
                onPressed: _fetchWeatherData, tooltip: 'Refresh Weather',
              )
            ],
          ),
        ],
      );
    }
    // Default message if data is still processing or unavailable
    return Text('Weather data processing...', style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSecondaryContainer.withOpacity(0.7)));
  }

  /// Helper function to build consistent info rows within the At a Glance card.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0, // No shadow for this card, as it's part of the main layout
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      color: theme.colorScheme.primaryContainer.withOpacity(0.5), // Uses the secondary container color
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                'At a Glance',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            _buildInfoRow(
              context: context,
              icon: Icons.thermostat_rounded,
              title: 'Weather',
              contentWidget: _buildWeatherContent(context),
            ),
            Divider(color: theme.colorScheme.onSecondaryContainer.withOpacity(0.2), height: 1),
            _buildInfoRow(
              context: context,
              icon: Icons.calendar_today_rounded,
              title: 'Date',
              contentWidget: Text(
                widget.formattedDate, // Displays the formatted date passed from Home Page
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
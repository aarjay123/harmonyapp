import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:geolocator/geolocator.dart'; // For getting user location
import 'package:http/http.dart' as http; // For making API requests
import 'dart:convert'; // For decoding JSON
import 'dart:async'; // For TimeoutException

// Model to hold weather data
class WeatherData {
  final String cityName;
  final String description;
  final double temperature; // Celsius
  final String iconCode;
  final bool isFallback; // To indicate if this is fallback data

  WeatherData({
    required this.cityName,
    required this.description,
    required this.temperature,
    required this.iconCode,
    this.isFallback = false,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, {bool isFallback = false}) {
    // Helper to safely get nested values
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
      description: _safeGet<String>(json, ['weather', '0', 'description'], 'No description')!,
      temperature: (_safeGet<num>(json, ['main', 'temp'], 273.15)!.toDouble() - 273.15), // Kelvin to Celsius, default to 0°C
      iconCode: _safeGet<String>(json, ['weather', '0', 'icon'], '01d')!,
      isFallback: isFallback,
    );
  }
}

class NativeWelcomePage extends StatefulWidget {
  const NativeWelcomePage({super.key});

  @override
  State<NativeWelcomePage> createState() => _NativeWelcomePageState();
}

class _NativeWelcomePageState extends State<NativeWelcomePage> {
  String _greeting = '';
  String _formattedDate = '';
  WeatherData? _weatherData;
  bool _isLoadingWeather = true;
  String? _weatherError;

  // IMPORTANT: User has inserted their key here
  final String _apiKey = 'b9c22dc18482e0924657dbf0ea281d35';

  // Fallback coordinates for Carnforth, UK
  static const double _carnforthLat = 54.1300;
  static const double _carnforthLon = -2.7700;

  @override
  void initState() {
    super.initState();
    _updateGreetingAndDate();
    _fetchWeatherData(); // Initial fetch attempts user's location
  }

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
    _formattedDate = DateFormat('EEEE, d MMMM yyyy').format(now);
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    debugPrint("Checking location service...");
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("Location service disabled.");
      if (mounted) setState(() => _weatherError = 'Location services are disabled. Showing weather for Carnforth, UK.');
      return null;
    }
    debugPrint("Location service enabled.");

    debugPrint("Checking location permission...");
    permission = await Geolocator.checkPermission();
    debugPrint("Initial permission status: $permission");

    if (permission == LocationPermission.denied) {
      debugPrint("Location permission denied, requesting...");
      permission = await Geolocator.requestPermission();
      debugPrint("Permission status after request: $permission");
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _weatherError = 'Location permission denied. Showing weather for Carnforth, UK.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("Location permission denied forever.");
      if (mounted) setState(() => _weatherError = 'Location permission permanently denied. Showing weather for Carnforth, UK.');
      return null;
    }

    debugPrint("Permission granted. Getting current position...");
    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15)
      );
    } on TimeoutException catch (e, st) {
      debugPrint("Timeout getting location: $e\n$st");
      if (mounted) setState(() => _weatherError = 'Could not get current location. Showing weather for Carnforth, UK.');
      return null;
    } catch (e, st) {
      debugPrint("Error getting location: $e\n$st");
      if (mounted) setState(() => _weatherError = 'Error getting location. Showing weather for Carnforth, UK.');
      return null;
    }
  }

  Future<void> _fetchWeatherForCoordinates(double lat, double lon, {bool isFallback = false}) async {
    if (!mounted) return;
    // Ensure loading state is true if we are calling this directly or as a fallback
    if (isFallback || _weatherData == null) { // Also set loading if no data yet
      setState(() {
        _isLoadingWeather = true;
        // Clear previous API error if this is a new attempt, keep location error if it's a fallback
        if (!isFallback) _weatherError = null;
      });
    }


    final uri = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey');
    debugPrint("Fetching weather from: $uri (Fallback: $isFallback)");

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        setState(() {
          _weatherData = WeatherData.fromJson(decodedJson, isFallback: isFallback);
          _isLoadingWeather = false;
          if (isFallback && _weatherError == null) { // Clear generic location error if fallback succeeds
            _weatherError = null; // Or set a specific message: "Showing fallback weather for Carnforth."
          } else if (isFallback && _weatherError != null && _weatherError!.contains("Location")) {
            // If a location error was set, and fallback worked, we might want to indicate it.
            // For now, success means _weatherData is set, and error is cleared or not set by API.
          }
        });
      } else {
        debugPrint("Failed to load weather data for coords. Status: ${response.statusCode}, Body: ${response.body}");
        setState(() {
          _weatherError = 'Failed to load weather data (Error: ${response.statusCode})';
          if (isFallback) _weatherError = 'Failed to load fallback weather data.';
          _isLoadingWeather = false;
        });
      }
    } catch (e, st) {
      if (!mounted) return;
      debugPrint('CRITICAL: Weather fetch error for coords: $e\nStackTrace: $st');
      setState(() {
        _weatherError = 'Failed to fetch weather data. Check connection.';
        if (isFallback) _weatherError = 'Failed to fetch fallback weather data.';
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _fetchWeatherData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingWeather = true;
      _weatherError = null; // Clear previous errors on new attempt
    });

    if (_apiKey == 'YOUR_OPENWEATHERMAP_API_KEY' || _apiKey.isEmpty) {
      if (mounted) {
        setState(() {
          _weatherError = 'Weather API key not configured.';
          _isLoadingWeather = false;
        });
      }
      return;
    }

    Position? position = await _determinePosition();

    if (position != null) {
      // Got user's position, fetch weather for it
      await _fetchWeatherForCoordinates(position.latitude, position.longitude);
    } else {
      // Failed to get user's position, _weatherError should already be set by _determinePosition
      // Now fetch for fallback location
      debugPrint("Fetching fallback weather for Carnforth, UK.");
      // The _weatherError might already be set to a location specific issue.
      // We can choose to show that error, or overwrite if fallback fails.
      await _fetchWeatherForCoordinates(_carnforthLat, _carnforthLon, isFallback: true);
    }
  }


  Widget _buildWeatherContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoadingWeather) {
      return Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.0, color: colorScheme.onSecondaryContainer),
          ),
          const SizedBox(width: 12),
          Text(
            'Fetching weather...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      );
    }

    if (_weatherError != null && _weatherData == null) { // Show error only if no weather data is available (even fallback)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _weatherError!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7)),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: _fetchWeatherData, // This will retry getting current location first
            tooltip: 'Retry',
          )
        ],
      );
    }

    if (_weatherData != null) {
      String weatherLocationName = _weatherData!.cityName;
      if (_weatherData!.isFallback && (_weatherError != null && _weatherError!.toLowerCase().contains("location"))) {
        // If it's fallback due to location error, keep the error message visible or modify it.
        // For now, we just show the fallback city name. User will see the initial location error.
      }

      return Column( // Allow error message and weather data to coexist if needed
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_weatherError != null && _weatherData!.isFallback) // Show location error message if fallback is active
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _weatherError!, // Show the original location error
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
                width: 48,
                height: 48,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.cloud_off_rounded, color: colorScheme.onSecondaryContainer, size: 30),
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: colorScheme.onSecondaryContainer,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$weatherLocationName - ${_weatherData!.temperature.toStringAsFixed(1)}°C',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _weatherData!.description[0].toUpperCase() + _weatherData!.description.substring(1),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7)),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _fetchWeatherData,
                tooltip: 'Refresh Weather',
              )
            ],
          ),
        ],
      );
    }
    // Fallback if no data and no specific error message set by logic above
    return Text(
      'Weather data processing...', // Should be brief if seen
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSecondaryContainer.withOpacity(0.7),
      ),
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
      body: RefreshIndicator(
        onRefresh: _fetchWeatherData,
        color: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting!',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        foreground: Paint()..shader = greetingGradientShader,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome to Harmony!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5))
                ),
                color: colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Info',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.thermostat_rounded,
                        title: 'Weather',
                        titleColor: colorScheme.onSecondaryContainer,
                        contentWidget: _buildWeatherContent(context),
                        iconColor: colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(height: 16.0),
                      Divider(color: colorScheme.onSecondaryContainer.withOpacity(0.2)),
                      const SizedBox(height: 16.0),
                      _buildInfoRow(
                        context: context,
                        icon: Icons.calendar_today_rounded,
                        title: 'Date',
                        titleColor: colorScheme.onSecondaryContainer,
                        contentWidget: Text(
                          _formattedDate,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        iconColor: colorScheme.onSecondaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildActionChip(
                      context: context,
                      icon: Icons.restaurant_menu_rounded,
                      label: 'Order Food',
                      onTap: () {
                        // TODO: Implement action
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionChip(
                      context: context,
                      icon: Icons.hotel_rounded,
                      label: 'Book Stay',
                      onTap: () {
                        // TODO: Implement action
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget contentWidget,
    Color? iconColor,
    Color? titleColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor ?? colorScheme.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: titleColor ?? colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              contentWidget,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ActionChip(
      avatar: Icon(icon, size: 20, color: colorScheme.primary),
      label: Text(label),
      onPressed: onTap,
      labelStyle: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onPrimaryContainer),
      backgroundColor: colorScheme.primaryContainer.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        // side: BorderSide(color: colorScheme.outline.withOpacity(0.7)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

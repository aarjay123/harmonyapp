import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:geolocator/geolocator.dart'; // For getting user location
import 'package:http/http.dart' as http; // For making API requests
import 'dart:convert'; // For decoding JSON
import 'dart:async'; // For TimeoutException

// Model to hold weather data
class WeatherData {
  final String cityName;
  // final String description; // Description is no longer displayed
  final double temperature; // Celsius
  final String iconCode;
  final bool isFallback; // To indicate if this is fallback data

  WeatherData({
    required this.cityName,
    // required this.description,
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
      // description: _safeGet<String>(json, ['weather', '0', 'description'], '')!, // Not displayed, but kept in model
      temperature: (_safeGet<num>(json, ['main', 'temp'], 273.15)!.toDouble() - 273.15),
      iconCode: _safeGet<String>(json, ['weather', '0', 'icon'], '01d')!,
      isFallback: isFallback,
    );
  }
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
  WeatherData? _weatherData;
  bool _isLoadingWeather = true;
  String? _weatherError;

  final String _apiKey = 'b9c22dc18482e0924657dbf0ea281d35';
  static const double _carnforthLat = 54.1300;
  static const double _carnforthLon = -2.7700;

  // Max width for the main content area on larger screens
  static const double _contentMaxWidth = 768.0;


  @override
  void initState() {
    super.initState();
    _updateGreetingAndDate();
    _fetchWeatherData();
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
    _formattedDate = DateFormat('EEEE, d MMMM yyyy').format(now); // Corrected format
    if (mounted) setState(() {});
  }

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

  Future<void> _fetchWeatherForCoordinates(double lat, double lon, {bool isFallback = false}) async {
    if (!mounted) return;
    if (isFallback || _weatherData == null) {
      setState(() {
        _isLoadingWeather = true;
        if (!isFallback) _weatherError = null;
      });
    }
    final uri = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        setState(() {
          _weatherData = WeatherData.fromJson(decodedJson, isFallback: isFallback);
          _isLoadingWeather = false;
          if (isFallback && (_weatherError == null || !_weatherError!.toLowerCase().contains("location"))) {
            _weatherError = null;
          }
        });
      } else {
        setState(() {
          _weatherError = 'Failed to load weather (Error: ${response.statusCode})';
          if (isFallback) _weatherError = 'Failed to load fallback weather.';
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _weatherError = 'Failed to fetch weather. Check connection.';
        if (isFallback) _weatherError = 'Failed to fetch fallback weather.';
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _fetchWeatherData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
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
      await _fetchWeatherForCoordinates(position.latitude, position.longitude);
    } else {
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
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: colorScheme.onSecondaryContainer), // Adjusted color
          ),
          const SizedBox(width: 16),
          Text(
            'Fetching weather...',
            style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSecondaryContainer), // Adjusted color
          ),
        ],
      );
    }
    if (_weatherError != null && _weatherData == null) {
      return ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 28),
        title: Text(_weatherError!, style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.error)),
        trailing: IconButton(
          icon: Icon(Icons.refresh_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7)), // Adjusted color
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
          if (_weatherError != null && _weatherData!.isFallback)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7), size: 18), // Adjusted color
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _weatherError!,
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSecondaryContainer.withOpacity(0.7)), // Adjusted color
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
                errorBuilder: (context, error, stackTrace) => Icon(Icons.cloud_off_rounded, color: colorScheme.onSecondaryContainer, size: 30), // Adjusted color
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(width: 48, height: 48, child: Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null, color: colorScheme.onSecondaryContainer, strokeWidth: 2.0,))); // Adjusted color
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '${_weatherData!.cityName} - ${_weatherData!.temperature.toStringAsFixed(1)}°C',
                  style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.w500), // Adjusted color
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: colorScheme.onSecondaryContainer.withOpacity(0.7)), // Adjusted color
                onPressed: _fetchWeatherData, tooltip: 'Refresh Weather',
              )
            ],
          ),
        ],
      );
    }
    return Text('Weather data processing...', style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSecondaryContainer.withOpacity(0.7))); // Adjusted color
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget contentWidget,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.onSecondaryContainer, size: 28), // Icon color to match card content
      title: Text(title, style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.w500)), // Text color to match
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: contentWidget,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
    );
  }

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
          child: Center( // Center the content column
            child: ConstrainedBox( // Constrain its width
              constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
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
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    color: colorScheme.secondaryContainer, // Ensuring this card uses secondaryContainer
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
                                color: colorScheme.onSecondaryContainer, // Text on secondaryContainer
                              ),
                            ),
                          ),
                          _buildInfoRow(
                            context: context,
                            icon: Icons.thermostat_rounded,
                            title: 'Weather',
                            contentWidget: _buildWeatherContent(context),
                          ),
                          Divider(color: colorScheme.onSecondaryContainer.withOpacity(0.2), height: 1), // Adjusted divider color
                          _buildInfoRow(
                            context: context,
                            icon: Icons.calendar_today_rounded,
                            title: 'Date',
                            contentWidget: Text(
                              _formattedDate,
                              style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSecondaryContainer), // Adjusted text color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      'Quick Actions',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
                  const SizedBox(height: 24.0),
                  Card(
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
                              Icon(Icons.campaign_rounded, color: colorScheme.onTertiaryContainer, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                "Special Offer!",
                                style: theme.textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Enjoy 15% off all appetizers this weekend when you order through the app!",
                            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onTertiaryContainer),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.tonalIcon(
                              onPressed: () => widget.onNavigateToTab(1),
                              icon: Icon(Icons.local_offer_rounded, size: 18),
                              label: const Text("View Offer"),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
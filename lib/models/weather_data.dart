import 'dart:convert'; // For decoding JSON

/// Model to hold weather data fetched from OpenWeatherMap API.
class WeatherData {
  final String cityName;
  final double temperature; // Temperature in Celsius
  final String iconCode;   // OpenWeatherMap icon code (e.g., '01d', '04n')
  final bool isFallback;   // Indicates if this data is from a fallback location (e.g., when GPS fails)

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.iconCode,
    this.isFallback = false,
  });

  /// Factory constructor to create a WeatherData object from a JSON map.
  /// It safely extracts values, providing default values if keys are missing or types are incorrect.
  factory WeatherData.fromJson(Map<String, dynamic> json, {bool isFallback = false}) {
    // Helper function for safe retrieval of nested JSON values.
    T? _safeGet<T>(Map<String, dynamic> map, List<String> keys, [T? defaultValue]) {
      dynamic current = map;
      for (String key in keys) {
        if (current is Map<String, dynamic> && current.containsKey(key)) {
          current = current[key];
        } else {
          return defaultValue; // Return default if key is not found or type mismatch
        }
      }
      return current is T ? current : defaultValue; // Ensure final value is of expected type
    }

    return WeatherData(
      cityName: _safeGet<String>(json, ['name'], 'Unknown City')!,
      // Convert temperature from Kelvin (API default) to Celsius.
      temperature: (_safeGet<num>(json, ['main', 'temp'], 273.15)!.toDouble() - 273.15),
      iconCode: _safeGet<String>(json, ['weather', '0', 'icon'], '01d')!,
      isFallback: isFallback,
    );
  }
}
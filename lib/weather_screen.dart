import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http; // No longer needed directly
// import 'dart:convert'; // No longer needed directly

import 'package:flutter_weather_app/models/weather_info.dart';
import 'package:flutter_weather_app/services/weather_service.dart';
import 'package:flutter_weather_app/login_screen.dart';


class WeatherScreen extends StatefulWidget {
  WeatherScreen({super.key, WeatherService? weatherService})
    : _weatherService = weatherService ?? WeatherService(); // Allow injection for testing

  final WeatherService _weatherService;
  static const String routeName = '/weather';

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _isLoading = true;
  WeatherInfo? _weatherInfo;
  String? _errorMessage;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weatherInfo = null;
      _currentPosition = null;
    });

    Position? obtainedPosition;
    bool locationAttempted = false; // To track if we tried to get location
    bool locationErrorOccurred = false;
    // String locationErrorMsgForSnackbar = ''; // Unused

    try {
      locationAttempted = true;
      obtainedPosition = await widget._weatherService.getCurrentLocation();
      _currentPosition = obtainedPosition; // Store for display if successful
    } catch (e) {
      locationErrorOccurred = true;
      // locationErrorMsgForSnackbar = e.toString().replaceFirst("Exception: ", ""); // Unused
      // Don't set _errorMessage state here yet, handle it consistently after deciding fetch path.
    }

    try {
      WeatherInfo weather;
      String? informationalMessage; // For messages that accompany data

      if (locationErrorOccurred || obtainedPosition == null) {
        // SnackBars removed from here. Messages will be set to _errorMessage.

        weather = await widget._weatherService.fetchWeatherByCityName(defaultCityName); // Using imported const
        if (locationErrorOccurred) {
          informationalMessage = "Showing weather for default location due to location error.";
        } else if (locationAttempted && obtainedPosition == null) { // It was attempted, but result was null
          informationalMessage = "Location unavailable, showing default.";
        }
        // If location was not attempted (e.g., a direct call to fetch by city in future), informationalMessage remains null.

      } else { // Location succeeded and obtainedPosition is not null
        weather = await widget._weatherService.fetchWeather(position: obtainedPosition);
        informationalMessage = null; // Clear any previous informational error on primary success
      }

      if (mounted) {
        setState(() {
          _weatherInfo = weather;
          _isLoading = false;
          _errorMessage = informationalMessage; // This can be null or the info message
        });
      }
    } catch (e) { // This outer catch handles API errors from fetchWeather or fetchWeatherByCityName
      String displayError = e.toString().replaceFirst("Exception: ", "");
      bool isApiKeyError = displayError.toLowerCase().contains("api key missing");

      if (mounted && !isApiKeyError) {
        // Attempt fallback for non-API key errors
        // SnackBar removed from here for initial load.
        // The error message will be set in _errorMessage.
        try {
          final fallbackWeather = await widget._weatherService.fetchWeatherByCityName(defaultCityName);
          setState(() {
            _weatherInfo = fallbackWeather;
            _isLoading = false;
            _errorMessage = "Showing default due to API error: $displayError"; // Informational, but indicates an issue
          });
        } catch (fallbackException) {
          setState(() {
            _weatherInfo = null; // No weather data to show
            _isLoading = false;
            _errorMessage = 'API Error: $displayError. Fallback also failed: ${fallbackException.toString().replaceFirst("Exception: ", "")}';
          });
        }
      } else { // API Key error, or not mounted
        setState(() {
          _weatherInfo = null;
          _isLoading = false;
          _errorMessage = displayError; // Critical error (e.g. API key)
        });
      }
    }
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchWeatherData, // Disable while loading
            tooltip: 'Refresh Weather',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // Responsive constraint
          child: _buildWeatherContent(),
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    // Prioritize error message if weatherInfo is null
    if (_weatherInfo == null && _errorMessage != null) {
      return SingleChildScrollView( // Added SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _fetchWeatherData, child: const Text("Try Again"))
              ]
          )
        ),
      );
    }

    // If weatherInfo is available, display it, potentially with a non-critical error message
    if (_weatherInfo != null) {
      final weather = _weatherInfo!;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Show non-critical error/info message if present (e.g., "showing default location")
            if (_errorMessage != null && _weatherInfo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.purple, fontSize: 20, fontWeight: FontWeight.bold), // Prominent style
                  textAlign: TextAlign.center,
                ),
              ),
            Text(
              weather.cityName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Image.network(weather.iconUrl, scale: 0.7, errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.cloud_off, size: 64, color: Colors.grey); // Placeholder for failed icon
            }),
            const SizedBox(height: 16.0),
            Text(
              '${weather.temperature.toStringAsFixed(1)}°C',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              weather.description.split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' '), // Capitalize each word
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoChip(icon: Icons.water_drop, label: 'Humidity', value: '${weather.humidity}%'),
                _InfoChip(icon: Icons.air, label: 'Wind', value: '${weather.windSpeed.toStringAsFixed(1)} m/s'),
              ],
            ),
             if (_currentPosition != null) ...[
              const SizedBox(height: 20),
              Text(
                'Location: Lat: ${_currentPosition!.latitude.toStringAsFixed(2)}, Lon: ${_currentPosition!.longitude.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
      );
    }
    // Fallback if neither loading, error (without weather), nor weather info is available
    return const Text('No weather data available. Try refreshing.');
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_weather_app/models/weather_info.dart';

// TODO: Replace with your own OpenWeatherMap API key
const String openWeatherMapApiKey = 'YOUR_API_KEY_HERE';
const String defaultCityName = 'London'; // Default location

class WeatherService {
  final http.Client httpClient;

  // Allow injecting an http.Client for testing
  WeatherService({http.Client? client}) : httpClient = client ?? http.Client();

  Future<Position?>getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  Future<WeatherInfo> fetchWeather({Position? position}) async {
    if (openWeatherMapApiKey == 'YOUR_API_KEY_HERE') {
      throw Exception(
          'API Key Missing: Please replace "YOUR_API_KEY_HERE" with your actual OpenWeatherMap API key in weather_service.dart');
    }

    String apiUrl;

    if (position != null) {
      final lat = position.latitude;
      final lon = position.longitude;
      apiUrl =
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$openWeatherMapApiKey';
    } else {
      // Fallback to default city if position is null
      // This case should ideally be decided by the caller (e.g. WeatherScreen state)
      // but is included here as a basic fallback for the service.
      debugPrint("Position is null, attempting to fetch weather for default city: $defaultCityName");
      apiUrl =
          'https://api.openweathermap.org/data/2.5/weather?q=$defaultCityName&units=metric&appid=$openWeatherMapApiKey';
    }

    try {
      final response = await httpClient.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherInfo.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to load weather data: ${errorData['message'] ?? 'Unknown API error'} (Code: ${response.statusCode})');
      }
    } catch (e) {
      // Catching potential http client errors or json decoding errors
      throw Exception('Network or API error: $e');
    }
  }

  Future<WeatherInfo> fetchWeatherByCityName(String cityName) async {
    if (openWeatherMapApiKey == 'YOUR_API_KEY_HERE') {
      throw Exception(
          'API Key Missing: Please replace "YOUR_API_KEY_HERE" with your actual OpenWeatherMap API key in weather_service.dart');
    }
    final apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&units=metric&appid=$openWeatherMapApiKey';

    try {
      final response = await httpClient.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherInfo.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to load weather for $cityName: ${errorData['message'] ?? 'Unknown API error'} (Code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network or API error fetching for $cityName: $e');
    }
  }
}

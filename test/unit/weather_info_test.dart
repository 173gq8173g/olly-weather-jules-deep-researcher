import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_app/models/weather_info.dart';

void main() {
  group('WeatherInfo.fromJson', () {
    test('should correctly parse valid JSON', () {
      const jsonString = '''
      {
        "weather": [
          {
            "description": "clear sky",
            "icon": "01d"
          }
        ],
        "main": {
          "temp": 25.5,
          "humidity": 60
        },
        "wind": {
          "speed": 5.5
        },
        "name": "Mountain View"
      }
      ''';
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final weatherInfo = WeatherInfo.fromJson(jsonMap);

      expect(weatherInfo.cityName, 'Mountain View');
      expect(weatherInfo.temperature, 25.5);
      expect(weatherInfo.description, 'clear sky');
      expect(weatherInfo.iconCode, '01d');
      expect(weatherInfo.humidity, 60);
      expect(weatherInfo.windSpeed, 5.5);
      expect(weatherInfo.iconUrl, 'https://openweathermap.org/img/wn/01d@2x.png');
    });

    test('should handle missing optional fields with default values', () {
      const jsonString = '''
      {
        "main": {
          "temp": 10.0
        },
        "name": "Test City No Weather"
      }
      ''';
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final weatherInfo = WeatherInfo.fromJson(jsonMap);

      expect(weatherInfo.cityName, 'Test City No Weather');
      expect(weatherInfo.temperature, 10.0);
      expect(weatherInfo.description, 'No description'); // Default
      expect(weatherInfo.iconCode, '01d'); // Default
      expect(weatherInfo.humidity, 0); // Default
      expect(weatherInfo.windSpeed, 0.0); // Default
    });

    test('should handle completely empty or malformed main/weather parts', () {
      const jsonString = '''
      {
        "name": "Test City Only Name"
      }
      ''';
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final weatherInfo = WeatherInfo.fromJson(jsonMap);

      expect(weatherInfo.cityName, 'Test City Only Name');
      expect(weatherInfo.temperature, 0.0); // Default
      expect(weatherInfo.description, 'No description'); // Default
      expect(weatherInfo.iconCode, '01d'); // Default
      expect(weatherInfo.humidity, 0); // Default
      expect(weatherInfo.windSpeed, 0.0); // Default
    });

     test('should handle null name field with default value', () {
      const jsonString = '''
      {
        "weather": [
          {
            "description": "cloudy",
            "icon": "02d"
          }
        ],
        "main": {
          "temp": 15.0,
          "humidity": 70
        },
        "wind": {
          "speed": 3.0
        },
        "name": null
      }
      ''';
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final weatherInfo = WeatherInfo.fromJson(jsonMap);

      expect(weatherInfo.cityName, 'Unknown City'); // Default for null name
      expect(weatherInfo.temperature, 15.0);
      expect(weatherInfo.description, 'cloudy');
    });

    test('should handle temperature being an integer', () {
      const jsonString = '''
      {
        "main": {
          "temp": 20,
          "humidity": 50
        },
        "name": "Int Temp City"
      }
      ''';
       final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final weatherInfo = WeatherInfo.fromJson(jsonMap);
      expect(weatherInfo.temperature, 20.0);
      expect(weatherInfo.humidity, 50);
    });

  });
}

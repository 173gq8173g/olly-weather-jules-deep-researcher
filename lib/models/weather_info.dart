class WeatherInfo {
  final String cityName;
  final double temperature; // Celsius
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed; // m/s

  WeatherInfo({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      cityName: json['name'] ?? 'Unknown City',
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      description: json['weather']?[0]?['description'] ?? 'No description',
      iconCode: json['weather']?[0]?['icon'] ?? '01d', // Default to sunny
      humidity: (json['main']?['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}

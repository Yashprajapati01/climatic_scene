import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Weather {
final double temperature;
final double feelsLike;
final double tempMin;
final double tempMax;
final int pressure;
final int humidity;
final String description;
final String icon;
final String main;
final double windSpeed;
final int windDegree;
final String cityName;
final DateTime dateTime;

Weather({
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.description,
    required this.icon,
    required this.main,
    required this.windSpeed,
    required this.windDegree,
    required this.cityName,
    required this.dateTime,
});

factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
    temperature: json['main']['temp'].toDouble(),
    feelsLike: json['main']['feels_like'].toDouble(),
    tempMin: json['main']['temp_min'].toDouble(),
    tempMax: json['main']['temp_max'].toDouble(),
    pressure: json['main']['pressure'],
    humidity: json['main']['humidity'],
    description: json['weather'][0]['description'],
    icon: json['weather'][0]['icon'],
    main: json['weather'][0]['main'],
    windSpeed: json['wind']['speed'].toDouble(),
    windDegree: json['wind']['deg'],
    cityName: json['name'],
    dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
    );
}

String getIconUrl() {
    return 'https://openweathermap.org/img/wn/$icon@2x.png';
}

String getFormattedDate() {
    return DateFormat('EEEE, MMMM d').format(dateTime);
}

String getFormattedTime() {
    return DateFormat('h:mm a').format(dateTime);
}

String getFormattedTemperature() {
    return '${temperature.toStringAsFixed(1)}°C';
}

String getFormattedDescription() {
    return description.substring(0, 1).toUpperCase() + description.substring(1);
}
}

class WeatherService {
final String apiKey;
final String baseUrl = 'https://api.openweathermap.org/data/2.5';

WeatherService({required this.apiKey});

Future<Weather> getWeatherByCoordinates(double latitude, double longitude) async {
    final url = '$baseUrl/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey';
    
    try {
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Weather.fromJson(jsonData);
    } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
    }
    } catch (e) {
    throw Exception('Failed to fetch weather data: $e');
    }
}

Future<Weather> getWeatherByCityName(String cityName) async {
    final url = '$baseUrl/weather?q=$cityName&units=metric&appid=$apiKey';
    
    try {
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Weather.fromJson(jsonData);
    } else {
        throw Exception('Failed to load weather data for $cityName: ${response.statusCode}');
    }
    } catch (e) {
    throw Exception('Failed to fetch weather data for $cityName: $e');
    }
}

}



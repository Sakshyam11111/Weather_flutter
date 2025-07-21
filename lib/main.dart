import 'package:flutter/material.dart';
import 'package:weatherapp/pages/weather_home_page.dart';


void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1A1B23),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Colors.white, fontSize: 80),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
          titleMedium: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const WeatherHomePage(),
    );
  }
}
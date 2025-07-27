import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/pages/theme_provider.dart';
import 'package:weatherapp/pages/weather_home_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const WeatherApp(),
    ),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Weather App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: themeProvider.isDarkTheme
                ? const Color(0xFF1A1B23)
                : Colors.white,
            textTheme: TextTheme(
              headlineLarge: TextStyle(
                color: themeProvider.isDarkTheme ? Colors.white : Colors.black,
                fontSize: 80,
              ),
              bodyMedium: TextStyle(
                color: themeProvider.isDarkTheme
                    ? Colors.white70
                    : Colors.black87,
                fontSize: 16,
              ),
              titleMedium: TextStyle(
                color: themeProvider.isDarkTheme ? Colors.white : Colors.black,
                fontSize: 18,
              ),
            ),
            iconTheme: IconThemeData(
              color: themeProvider.isDarkTheme ? Colors.white70 : Colors.black87,
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: const WeatherHomePage(),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'info_card.dart';
import 'toggle_button.dart';
import 'forecast_card.dart';

class WeatherContent extends StatelessWidget {
  final double temperature;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final bool showToday;
  final List<Map<String, dynamic>> forecast;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> temperatureAnimation;
  final Animation<double> cardAnimation;
  final IconData Function(String) mapIconToIconData;
  final VoidCallback onToggleToday;
  final VoidCallback onToggleForecast;

  const WeatherContent({
    super.key,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.showToday,
    required this.forecast,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.temperatureAnimation,
    required this.cardAnimation,
    required this.mapIconToIconData,
    required this.onToggleToday,
    required this.onToggleForecast,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Main weather icon and temperature
              AnimatedBuilder(
                animation: temperatureAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: temperatureAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        mapIconToIconData(icon),
                        color: Colors.yellow,
                        size: 120,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Temperature display
              AnimatedBuilder(
                animation: temperatureAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: temperatureAnimation.value,
                    child: Column(
                      children: [
                        Text(
                          '${temperature.round()}°',
                          style: const TextStyle(
                            fontSize: 96,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          description.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 2,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 30),
              
              // Weather details cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InfoCard(
                    label: 'Humidity',
                    value: '$humidity%',
                    icon: Icons.water_drop,
                  ),
                  InfoCard(
                    label: 'Wind',
                    value: '${windSpeed.toStringAsFixed(1)} m/s',
                    icon: Icons.air,
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Toggle buttons
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ToggleButton(
                      text: 'TODAY',
                      isActive: showToday,
                      onTap: onToggleToday,
                    ),
                    ToggleButton(
                      text: 'FORECAST',
                      isActive: !showToday,
                      onTap: onToggleForecast,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Forecast cards
              AnimatedBuilder(
                animation: cardAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - cardAnimation.value)),
                    child: Opacity(
                      opacity: cardAnimation.value,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: forecast
                              .asMap()
                              .entries
                              .map((entry) => Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: ForecastCard(
                                      forecast: entry.value,
                                      index: entry.key,
                                      mapIconToIconData: mapIconToIconData,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
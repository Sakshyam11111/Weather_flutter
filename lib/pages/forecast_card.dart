import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class ForecastCard extends StatelessWidget {
  final Map<String, dynamic> forecast;
  final int index;
  final IconData Function(String) mapIconToIconData;

  const ForecastCard({
    super.key,
    required this.forecast,
    required this.index,
    required this.mapIconToIconData,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + (index * 200)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeProvider.isDarkTheme
                    ? [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ]
                    : [
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.05),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: themeProvider.isDarkTheme
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  forecast['day'],
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Icon(mapIconToIconData(forecast['icon']), size: 36),
                const SizedBox(height: 12),
                Text(
                  forecast['temp'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  forecast['description'],
                  style: TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

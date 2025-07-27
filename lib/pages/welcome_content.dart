import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class WelcomeContent extends StatelessWidget {
  const WelcomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wb_sunny,
            size: 120,
            color: Colors.yellow.withOpacity(0.8),
          ),
          const SizedBox(height: 30),
          Text(
            'Welcome to Weather Hub!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkTheme
                  ? Colors.white.withOpacity(0.9)
                  : Colors.black.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for any city to get started',
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.isDarkTheme
                  ? Colors.white.withOpacity(0.7)
                  : Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
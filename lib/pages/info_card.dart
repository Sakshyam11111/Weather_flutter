import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const InfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeProvider.isDarkTheme
              ? [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]
              : [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.05)],
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
          Icon(icon, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class ToggleButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const ToggleButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? (themeProvider.isDarkTheme
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.2))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive
                ? (themeProvider.isDarkTheme ? Colors.white : Colors.black)
                : (themeProvider.isDarkTheme
                    ? Colors.white.withOpacity(0.6)
                    : Colors.black.withOpacity(0.6)),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
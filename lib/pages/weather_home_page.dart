import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'weather_content.dart';
import 'welcome_content.dart';
import 'info_card.dart';
import 'toggle_button.dart';
import 'forecast_card.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with TickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  String _cityName = '';
  double? _temperature;
  String _description = '';
  String _icon = '';
  int? _humidity;
  double? _windSpeed;
  String _errorMessage = '';
  List<Map<String, dynamic>> _forecast = [];
  bool _isLoading = false;
  bool _showToday = true;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _temperatureController;
  late AnimationController _cardController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _temperatureAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _temperatureController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _temperatureAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _temperatureController,
      curve: Curves.bounceOut,
    ));

    _cardAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    ));

    // Start continuous animations
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _temperatureController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather(String city) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    const String apiKey = 'beb68caa757def4aad48a4d473795f8a';
    final String baseUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _cityName = data['name'];
          _temperature = data['main']['temp'].toDouble();
          _description = data['weather'][0]['description'];
          _icon = data['weather'][0]['icon'];
          _humidity = data['main']['humidity'];
          _windSpeed = data['wind']['speed'];
          _errorMessage = '';
          _isLoading = false;

          // Generate forecast data
          _forecast = List.generate(5, (index) {
            String forecastIcon = _getRandomIcon();
            return {
              'temp': '${(data['main']['temp'] - index).toStringAsFixed(0)}°/${(data['main']['temp'] + 5).toStringAsFixed(0)}°',
              'description': index == 0
                  ? 'Storm'
                  : index == 1
                      ? 'Shower'
                      : index == 2
                          ? 'Rain'
                          : index == 3
                              ? 'Cloudy'
                              : 'Sunny',
              'icon': forecastIcon,
              'day': _getDayName(index),
            };
          });
        });

        // Trigger animations
        _fadeController.forward();
        _slideController.forward();
        _temperatureController.forward();
        _cardController.forward();
      } else {
        setState(() {
          _errorMessage = 'City not found';
          _cityName = '';
          _temperature = null;
          _description = '';
          _icon = '';
          _humidity = null;
          _windSpeed = null;
          _forecast = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch weather data';
        _cityName = '';
        _temperature = null;
        _description = '';
        _icon = '';
        _humidity = null;
        _windSpeed = null;
        _forecast = [];
        _isLoading = false;
      });
    }
  }

  String _getRandomIcon() {
    final List<String> icons = ['10d', '09d', '02d', '03d', '01d'];
    return icons[DateTime.now().millisecond % icons.length];
  }

  String _getDayName(int index) {
    final days = ['Today', 'Tomorrow', 'Wed', 'Thu', 'Fri'];
    return days[index];
  }

  IconData _mapIconToIconData(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n':
        return Icons.wb_sunny;
      case '02d':
      case '02n':
        return Icons.wb_cloudy;
      case '03d':
      case '03n':
        return Icons.cloud;
      case '04d':
      case '04n':
        return Icons.cloudy_snowing;
      case '09d':
      case '09n':
        return Icons.grain;
      case '10d':
      case '10n':
        return Icons.umbrella;
      case '11d':
      case '11n':
        return Icons.flash_on;
      case '13d':
      case '13n':
        return Icons.ac_unit;
      case '50d':
      case '50n':
        return Icons.foggy;
      default:
        return Icons.help;
    }
  }

  Color _getBackgroundGradientColor() {
    if (_temperature == null) return const Color(0xFF1A1B23);

    if (_temperature! >= 30) {
      return const Color(0xFF2D1B69); // Hot purple
    } else if (_temperature! >= 20) {
      return const Color(0xFF1A472A); // Warm green
    } else if (_temperature! >= 10) {
      return const Color(0xFF2C5282); // Cool blue
    } else {
      return const Color(0xFF2A4365); // Cold dark blue
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getBackgroundGradientColor(),
              const Color(0xFF1A1B23),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with animated title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white70),
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _cityName.isNotEmpty ? _cityName : 'Weather Hub',
                        key: ValueKey(_cityName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.location_on, color: Colors.white70),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Animated search field
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'Search for a city...',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      suffixIcon: AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _isLoading ? _rotationAnimation.value : 0,
                            child: IconButton(
                              icon: Icon(
                                _isLoading ? Icons.refresh : Icons.search,
                                color: Colors.white70,
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      if (_cityController.text.isNotEmpty) {
                                        _fetchWeather(_cityController.text);
                                      }
                                    },
                            ),
                          );
                        },
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (value) {
                      if (value.isNotEmpty && !_isLoading) {
                        _fetchWeather(value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 40),
                // Weather content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : _errorMessage.isNotEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 60,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage,
                                    style: const TextStyle(color: Colors.red, fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : _temperature != null
                              ? WeatherContent(
                                  temperature: _temperature!,
                                  description: _description,
                                  icon: _icon,
                                  humidity: _humidity!,
                                  windSpeed: _windSpeed!,
                                  showToday: _showToday,
                                  forecast: _forecast,
                                  fadeAnimation: _fadeAnimation,
                                  slideAnimation: _slideAnimation,
                                  temperatureAnimation: _temperatureAnimation,
                                  cardAnimation: _cardAnimation,
                                  mapIconToIconData: _mapIconToIconData,
                                  onToggleToday: () {
                                    setState(() {
                                      _showToday = true;
                                    });
                                  },
                                  onToggleForecast: () {
                                    setState(() {
                                      _showToday = false;
                                    });
                                  },
                                )
                              : const WelcomeContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
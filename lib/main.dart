import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'dart:async'; 


import 'login_page.dart';
import 'signup_page.dart';
import 'glassmorphic_container.dart';
import 'theme_provider.dart';
import 'firebase_auth_implementation/firebase_auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
            apiKey: "AIzaSyBG76Xe-U-1XXeevaBpoTUXq3v43BNKFlE",
            authDomain: "weather-3bd18.firebaseapp.com",
            projectId: "weather-3bd18",
            storageBucket: "weather-3bd18.firebasestorage.app",
            messagingSenderId: "841896115697",
            appId: "1:841896115697:web:4c8e58db31857019f71850",
            measurementId: "G-CNE3400NV5",
          )
        : DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const WeatherApp(),
    ),
  );
}

class DefaultFirebaseOptions {
  static var currentPlatform;
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Weather Pro',
          theme: ThemeData(
            fontFamily: 'SF Pro Display',
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: themeProvider.isDarkTheme
                ? const Color(0xFF0D1117)
                : const Color(0xFFF8FAFC),
            textTheme: TextTheme(
              headlineLarge: TextStyle(
                color: themeProvider.isDarkTheme
                    ? Colors.white
                    : const Color(0xFF1E293B),
                fontSize: 80,
                fontWeight: FontWeight.w200,
                letterSpacing: -2,
              ),
              bodyMedium: TextStyle(
                color: themeProvider.isDarkTheme
                    ? Colors.white.withOpacity(0.8)
                    : const Color(0xFF475569),
                fontSize: 16,
              ),
              titleMedium: TextStyle(
                color: themeProvider.isDarkTheme
                    ? Colors.white
                    : const Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            iconTheme: IconThemeData(
              color: themeProvider.isDarkTheme
                  ? Colors.white.withOpacity(0.9)
                  : const Color(0xFF475569),
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  return const WeatherHomePage();
                }
                return const LoginPage();
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          routes: {
            '/login': (context) => const LoginPage(),
            '/signup': (context) => const SignUpPage(),
            '/home': (context) => const WeatherHomePage(),
          },
        );
      },
    );
  }
}

class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? accentColor;

  const InfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final color =
        accentColor ?? (themeProvider.isDarkTheme ? Colors.cyan : Colors.blue);

    return Expanded(
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkTheme
                    ? Colors.white
                    : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: themeProvider.isDarkTheme
                    ? Colors.white.withOpacity(0.7)
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ForecastCard extends StatelessWidget {
  final Map<String, dynamic> forecast;
  final int index;
  final IconData Function(String) mapIconToIconData;
  final bool isHourly;

  const ForecastCard({
    super.key,
    required this.forecast,
    required this.index,
    required this.mapIconToIconData,
    this.isHourly = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GlassmorphicContainer(
      width: isHourly ? 90 : 110,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Text(
            isHourly ? forecast['time'] : forecast['day'],
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkTheme
                  ? Colors.white.withOpacity(0.9)
                  : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.3),
                  Colors.orange.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              mapIconToIconData(forecast['icon']),
              size: isHourly ? 28 : 32,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            forecast['temp'],
            style: TextStyle(
              fontSize: isHourly ? 14 : 15,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkTheme
                  ? Colors.white
                  : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          if (!isHourly) ...[
            Text(
              forecast['description'],
              style: TextStyle(
                fontSize: 11,
                color: themeProvider.isDarkTheme
                    ? Colors.white.withOpacity(0.7)
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class ModernToggleButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const ModernToggleButton({
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
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: themeProvider.isDarkTheme
                      ? [
                          Colors.cyan.withOpacity(0.3),
                          Colors.blue.withOpacity(0.2)
                        ]
                      : [
                          Colors.blue.withOpacity(0.2),
                          Colors.cyan.withOpacity(0.1)
                        ],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(
                  color: themeProvider.isDarkTheme ? Colors.cyan : Colors.blue,
                  width: 1,
                )
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive
                ? (themeProvider.isDarkTheme ? Colors.cyan : Colors.blue)
                : (themeProvider.isDarkTheme
                    ? Colors.white.withOpacity(0.6)
                    : const Color(0xFF64748B)),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class WeatherContent extends StatelessWidget {
  final double temperature;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final bool showToday;
  final List<Map<String, dynamic>> forecast;
  final List<Map<String, dynamic>> todayHourly;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> temperatureAnimation;
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
    required this.todayHourly,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.temperatureAnimation,
    required this.mapIconToIconData,
    required this.onToggleToday,
    required this.onToggleForecast,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: temperatureAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * temperatureAnimation.value),
                  child: GlassmorphicContainer(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.amber.withOpacity(0.3),
                                Colors.orange.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Icon(
                            mapIconToIconData(icon),
                            color: Colors.amber,
                            size: 100,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '${temperature.round()}°',
                          style: TextStyle(
                            fontSize: 88,
                            fontWeight: FontWeight.w200,
                            color: themeProvider.isDarkTheme
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            letterSpacing: -3,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.withOpacity(0.2),
                                Colors.orange.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            description.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 1.5,
                              color: themeProvider.isDarkTheme
                                  ? Colors.amber.withOpacity(0.9)
                                  : Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                InfoCard(
                  label: 'Humidity',
                  value: '$humidity%',
                  icon: Icons.water_drop_outlined,
                  accentColor: Colors.blue,
                ),
                const SizedBox(width: 16),
                InfoCard(
                  label: 'Wind Speed',
                  value: '${windSpeed.toStringAsFixed(1)} m/s',
                  icon: Icons.air,
                  accentColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 32),
            GlassmorphicContainer(
              padding: const EdgeInsets.all(6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ModernToggleButton(
                    text: 'TODAY',
                    isActive: showToday,
                    onTap: onToggleToday,
                  ),
                  ModernToggleButton(
                    text: 'FORECAST',
                    isActive: !showToday,
                    onTap: onToggleForecast,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 16),
                  child: Text(
                    showToday ? 'Today\'s Forecast' : '5-Day Forecast',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkTheme
                          ? Colors.white.withOpacity(0.9)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: (showToday ? todayHourly : forecast)
                        .asMap()
                        .entries
                        .map((entry) => ForecastCard(
                              forecast: entry.value,
                              index: entry.key,
                              mapIconToIconData: mapIconToIconData,
                              isHourly: showToday,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeContent extends StatelessWidget {
  const WelcomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Center(
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.amber.withOpacity(0.3),
                    Colors.orange.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.wb_sunny,
                size: 80,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 32),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Welcome to Weather Pro',
                  textStyle: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkTheme
                        ? Colors.white
                        : const Color(0xFF1E293B),
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
            ),
            const SizedBox(height: 12),
            Text(
              'Get accurate weather forecasts\nfor any city worldwide',
              style: TextStyle(
                fontSize: 15,
                color: themeProvider.isDarkTheme
                    ? Colors.white.withOpacity(0.7)
                    : const Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with TickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  final FirebaseAuthServices _authServices = FirebaseAuthServices();
  String _cityName = '';
  double? _temperature;
  String _description = '';
  String _icon = '';
  int? _humidity;
  double? _windSpeed;
  String _errorMessage = '';
  List<Map<String, dynamic>> _forecast = [];
  List<Map<String, dynamic>> _todayHourly = [];
  bool _isLoading = false;
  bool _showToday = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _rotationController;
  late AnimationController _temperatureController;
  late AnimationController _breatheController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _temperatureAnimation;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _checkLocationPermissionAndFetch();
    } else {
      setState(() {
        _errorMessage = 'Enter a city to get weather data';
      });
    }
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _temperatureController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _breatheController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _temperatureAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _temperatureController, curve: Curves.elasticOut),
    );

    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _breatheController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _rotationController.dispose();
    _temperatureController.dispose();
    _breatheController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermissionAndFetch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied.';
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Location fetch timed out');
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Geocoding timed out');
      });

      String city = placemarks.isNotEmpty ? placemarks.first.locality ?? 'Unknown' : 'Unknown';
      _cityController.text = city;
      await _fetchWeather(city);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
        _isLoading = false;
      });
      print('Location error: $e');
    }
  }

  Future<void> _fetchWeather(String city) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    _rotationController.repeat();

    const String apiKey = 'beb68caa757def4aad48a4d473795f8a';
    final String baseUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _cityName = data['name'] ?? '';
          _temperature = data['main']['temp']?.toDouble();
          _description = data['weather'][0]['description'] ?? '';
          _icon = data['weather'][0]['icon'] ?? '';
          _humidity = data['main']['humidity']?.toInt();
          _windSpeed = data['wind']['speed']?.toDouble();
          _errorMessage = '';
          _isLoading = false;

          _forecast = List.generate(5, (index) {
            String forecastIcon = _getRandomIcon();
            return {
              'temp':
                  '${(data['main']['temp'] - index - 2).toStringAsFixed(0)}°/${(data['main']['temp'] + 3).toStringAsFixed(0)}°',
              'description': _getRandomDescription(index),
              'icon': forecastIcon,
              'day': _getDayName(index),
            };
          });

          _todayHourly = List.generate(8, (index) {
            final hour = (DateTime.now().hour + index) % 24;
            final temp = data['main']['temp'] + (math.Random().nextDouble() * 6 - 3);
            return {
              'temp': '${temp.toStringAsFixed(0)}°',
              'icon': _getRandomIcon(),
              'time': _formatHour(hour),
            };
          });
        });

        _rotationController.stop();
        _rotationController.reset();

        _fadeController.forward();
        _slideController.forward();
        _temperatureController.forward();
      } else {
        setState(() {
          _errorMessage = 'City not found. Please try again.';
          _cityName = '';
          _temperature = null;
          _description = '';
          _icon = '';
          _humidity = null;
          _windSpeed = null;
          _forecast = [];
          _todayHourly = [];
          _isLoading = false;
        });
        _rotationController.stop();
        _rotationController.reset();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection.';
        _cityName = '';
        _temperature = null;
        _description = '';
        _icon = '';
        _humidity = null;
        _windSpeed = null;
        _forecast = [];
        _todayHourly = [];
        _isLoading = false;
      });
      _rotationController.stop();
      _rotationController.reset();
      print('Weather fetch error: $e');
    }
  }

  String _getRandomIcon() {
    final List<String> icons = ['01d', '02d', '03d', '09d', '10d'];
    return icons[DateTime.now().millisecond % icons.length];
  }

  String _getRandomDescription(int index) {
    final descriptions = [
      'Sunny',
      'Partly Cloudy',
      'Cloudy',
      'Light Rain',
      'Clear'
    ];
    return descriptions[index % descriptions.length];
  }

  String _getDayName(int index) {
    final days = ['Today', 'Tomorrow', 'Wednesday', 'Thursday', 'Friday'];
    return days[index];
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
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
        return Icons.cloud_queue;
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
        return Icons.wb_sunny;
    }
  }

  List<Color> _getBackgroundGradient() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_temperature == null) {
      return themeProvider.isDarkTheme
          ? [const Color(0xFF0D1117), const Color(0xFF161B22)]
          : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)];
    }

    if (themeProvider.isDarkTheme) {
      if (_temperature! >= 30) {
        return [const Color(0xFF7C2D12), const Color(0xFF0D1117)];
      } else if (_temperature! >= 20) {
        return [const Color(0xFF166534), const Color(0xFF0D1117)];
      } else if (_temperature! >= 10) {
        return [const Color(0xFF1E40AF), const Color(0xFF0D1117)];
      } else {
        return [const Color(0xFF1E3A8A), const Color(0xFF0D1117)];
      }
    } else {
      if (_temperature! >= 30) {
        return [const Color(0xFFFEF3C7), const Color(0xFFF8FAFC)];
      } else if (_temperature! >= 20) {
        return [const Color(0xFFD1FAE5), const Color(0xFFF8FAFC)];
      } else if (_temperature! >= 10) {
        return [const Color(0xFFDBEAFE), const Color(0xFFF8FAFC)];
      } else {
        return [const Color(0xFFE0E7FF), const Color(0xFFF8FAFC)];
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _authServices.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error signing out: $e';
      });
      print('Logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _getBackgroundGradient(),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedBuilder(
                      animation: _breatheAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _breatheAnimation.value,
                          child: const GlassmorphicContainer(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.menu_rounded,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        _cityName.isNotEmpty ? _cityName : 'Weather Pro',
                        key: ValueKey(_cityName),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkTheme
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        GlassmorphicContainer(
                          padding: const EdgeInsets.all(12),
                          child: IconButton(
                            icon: Icon(
                              themeProvider.isDarkTheme
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              size: 24,
                            ),
                            onPressed: () {
                              themeProvider.toggleTheme();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        GlassmorphicContainer(
                          padding: const EdgeInsets.all(12),
                          child: IconButton(
                            icon: const Icon(
                              Icons.logout_rounded,
                              size: 24,
                            ),
                            onPressed: _logout,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                GlassmorphicContainer(
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: 'Search for a city...',
                      hintStyle: TextStyle(
                        color: themeProvider.isDarkTheme
                            ? Colors.white.withOpacity(0.6)
                            : const Color(0xFF64748B),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      suffixIcon: AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withOpacity(0.3),
                                  Colors.cyan.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Transform.rotate(
                              angle: _isLoading ? _rotationAnimation.value : 0,
                              child: IconButton(
                                icon: Icon(
                                  _isLoading
                                      ? Icons.refresh_rounded
                                      : Icons.search_rounded,
                                  color: themeProvider.isDarkTheme
                                      ? Colors.cyan
                                      : Colors.blue,
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        if (_cityController.text.isNotEmpty) {
                                          _fetchWeather(_cityController.text);
                                        }
                                      },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    style: TextStyle(
                      color: themeProvider.isDarkTheme
                          ? Colors.white
                          : const Color(0xFF1E293B),
                      fontSize: 16,
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty && !_isLoading) {
                        _fetchWeather(value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 60),
                            CircularProgressIndicator(
                              color: themeProvider.isDarkTheme
                                  ? Colors.cyan
                                  : Colors.blue,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Fetching weather data...',
                              style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.isDarkTheme
                                    ? Colors.white.withOpacity(0.7)
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _errorMessage.isNotEmpty
                        ? Center(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.isDarkTheme
                                    ? Colors.white.withOpacity(0.8)
                                    : const Color(0xFF64748B),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : _temperature != null &&
                                _humidity != null &&
                                _windSpeed != null
                            ? WeatherContent(
                                temperature: _temperature!,
                                description: _description,
                                icon: _icon,
                                humidity: _humidity!,
                                windSpeed: _windSpeed!,
                                showToday: _showToday,
                                forecast: _forecast,
                                todayHourly: _todayHourly,
                                fadeAnimation: _fadeAnimation,
                                slideAnimation: _slideAnimation,
                                temperatureAnimation: _temperatureAnimation,
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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
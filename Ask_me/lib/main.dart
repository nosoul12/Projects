import 'package:ai_based/Screen/chatScreen.dart';
import 'package:ai_based/Screen/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'const/cons.dart';

void main() {
  Gemini.init(apiKey: GEMINI_API_KEY);
  runApp(const GenerativeAISample());
}

class GenerativeAISample extends StatefulWidget {
  const GenerativeAISample({super.key});

  @override
  State<GenerativeAISample> createState() => _GenerativeAISampleState();
}

class _GenerativeAISampleState extends State<GenerativeAISample> {
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = !_isDarkTheme;
      prefs.setBool('isDarkTheme', _isDarkTheme);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doubt-Hunter',
      debugShowCheckedModeBanner: false,
      theme: _isDarkTheme ? _buildDarkTheme() : _buildLightTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => ChatScreen(
              title: 'Ask Me',
              toggleTheme: _toggleTheme,
              isDarkTheme: _isDarkTheme,
            ),
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD7CCC8),
        primary: const Color(0xFFD7CCC8),
        secondary: const Color(0xFF8D6E63),
        onPrimary: Colors.black,
        onSecondary: Colors.white,
      ),
      useMaterial3: true,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4E342E),
        brightness: Brightness.dark,
        primary: const Color(0xFF4E342E),
        secondary: const Color(0xFF8D6E63),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
      ),
      useMaterial3: true,
    );
  }
}

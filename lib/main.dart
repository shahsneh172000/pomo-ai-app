import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _languageCode = 'en';

  void _changeLanguage(String languageCode) {
    setState(() {
      _languageCode = languageCode;

    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anar Rakshak (ONNX - Leaf & Fruit)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.light),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green, brightness: Brightness.dark),
      ),
      themeMode: ThemeMode.dark,
      home: SplashScreen(
        languageCode: _languageCode,
        onLanguageChanged: _changeLanguage,
      ),
    );
  }
}

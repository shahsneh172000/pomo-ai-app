import 'dart:async';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'management_service.dart';
import 'model_service.dart';

class SplashScreen extends StatefulWidget {
  final String languageCode;
  final Function(String) onLanguageChanged;

  const SplashScreen({
    super.key,
    required this.languageCode,
    required this.onLanguageChanged,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;
  late ModelService _modelService;
  late ManagementService _managementService;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _modelService = ModelService();
    _managementService = ManagementService();
    _startLoading();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLoading() async {
    // Animate progress bar to give a sense of loading
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress += 0.01;
        if (_progress >= 0.9) {
          // Stop just before the end
          _progress = 0.9;
          timer.cancel();
        }
      });
    });

    // Actual loading of models and data
    try {
      await Future.wait([
        _modelService.loadModels(),
        _managementService.loadManagementData(),
      ]);
    } catch (e) {
      print("Error during splash screen loading: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load required data: $e')),
        );
      }
    }

    // Ensure progress bar completes visually
    if (mounted) {
      setState(() {
        _progress = 1.0;
      });
    }
    _timer?.cancel();

    // Short delay to let user see the full bar
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          languageCode: widget.languageCode,
          onLanguageChanged: widget.onLanguageChanged,
          modelService: _modelService,
          managementService: _managementService,
        ),
      ),
    );
  }

  Widget _buildGradientProgressBar(double progress) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade800, Colors.lightGreen],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: <Widget>[
          const Spacer(flex: 3),
          Image.asset('assets/app_icon.png', height: 150, width: 150),
          const SizedBox(height: 24),
          const Text('AnarRakshak', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.lightGreen)),
          const SizedBox(height: 8),
          Text('Your Pomegranate Farm Guard', style: TextStyle(fontSize: 17, color: isDarkMode ? Colors.white70 : Colors.black54)),
          const Spacer(flex: 4),
          const Text('Loading...', style: TextStyle(fontSize: 19)),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 60.0), child: _buildGradientProgressBar(_progress)),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
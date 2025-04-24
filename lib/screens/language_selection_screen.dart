import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import '../main.dart';
import 'home_Screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const LanguageSelectionScreen({super.key, required this.cameras});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final FlutterTts tts = FlutterTts();

  final List<Map<String, dynamic>> languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'ar', 'label': 'العربية'},
    {'code': 'fr', 'label': 'Français'},
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _speakInstructions();
  }

  Future<void> _speakInstructions() async {
    await _setTTSLanguage(languages[currentIndex]['code']);
    await tts.speak(
      "Swipe left or right to choose a language. Double tap to select.",
    );
    await Future.delayed(const Duration(seconds: 5));
    await _speakCurrentLanguage();
  }

  Future<void> _speakCurrentLanguage() async {
    await tts.stop();
    await _setTTSLanguage(languages[currentIndex]['code']);
    await tts.speak(languages[currentIndex]['label']);
  }

  Future<void> _setTTSLanguage(String code) async {
    switch (code) {
      case 'ar':
        await tts.setLanguage('ar-SA');
        break;
      case 'fr':
        await tts.setLanguage('fr-FR');
        break;
      default:
        await tts.setLanguage('en-US');
    }
  }

  void _nextLanguage() {
    setState(() {
      currentIndex = (currentIndex + 1) % languages.length;
    });
    _speakCurrentLanguage();
  }

  void _prevLanguage() {
    setState(() {
      currentIndex = (currentIndex - 1 + languages.length) % languages.length;
    });
    _speakCurrentLanguage();
  }

  void _selectLanguage() {
    String selectedCode = languages[currentIndex]['code'];
    MyApp.of(context)?.setLocale(Locale(selectedCode));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WelcomeCenterScreen(cameras: widget.cameras),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          _nextLanguage();
        } else if (details.primaryVelocity! > 0) {
          _prevLanguage();
        }
      },
      onDoubleTap: _selectLanguage,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color.fromARGB(255, 135, 145, 255)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.language,
                    size: 80,
                    color: Color.fromARGB(255, 135, 145, 255),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Please choose your language',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    languages[currentIndex]['label'],
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Swipe left or right to change.Double tap to select.',
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:vibration/vibration.dart'; // added
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
    {'code': 'ar', 'label': 'العربية'}, // Arabic first
    {'code': 'fr', 'label': 'Français'}, // French second
    {'code': 'en', 'label': 'English'}, // English last
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _speakInstructions();
  }

  Future<void> _speakInstructions() async {
    await _setTTSLanguage(languages[currentIndex]['code']);
    await tts.speak("اسحب لليمين لاختيار اللغة. انقر مرتين للتأكيد.");
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

  Future<void> _vibrateShort() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  Future<void> _vibrateStrong() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200);
    }
  }

  void _nextLanguage() {
    setState(() {
      currentIndex = (currentIndex + 1) % languages.length;
    });
    _vibrateShort(); // short vibration on swipe
    _speakCurrentLanguage();
  }

  void _prevLanguage() {
    setState(() {
      currentIndex = (currentIndex - 1 + languages.length) % languages.length;
    });
    _vibrateShort(); // short vibration on swipe
    _speakCurrentLanguage();
  }

  Future<void> _selectLanguage() async {
    await _vibrateStrong(); // strong vibration on select
    String selectedCode = languages[currentIndex]['code'];
    String selectedLabel = languages[currentIndex]['label'];

    await _setTTSLanguage(selectedCode);
    await tts.speak(
      selectedCode == 'ar'
          ? "لقد اخترت $selectedLabel."
          : selectedCode == 'fr'
          ? "Vous avez choisi $selectedLabel. "
          : "You selected $selectedLabel. ",
    );

    await Future.delayed(const Duration(seconds: 4)); // allow TTS to finish
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
                    'Swipe left or right to change. Double tap to select.',
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

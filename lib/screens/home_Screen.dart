import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'text_Screen.dart';
import 'money_Screen.dart' as money;
import 'object_Screen.dart' as object;
import 'package:camera/camera.dart';

class WelcomeCenterScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const WelcomeCenterScreen({super.key, required this.cameras});

  @override
  State<WelcomeCenterScreen> createState() => _WelcomeCenterScreenState();
}

class _WelcomeCenterScreenState extends State<WelcomeCenterScreen> {
  final FlutterTts tts = FlutterTts();
  List<CameraDescription> get cameras => widget.cameras;
  int currentIndex = 0;

  final List<String> features = [
    "Welcome Page",
    "Money Recognition",
    "Text Recognition",
    "Object Detection",
  ];

  @override
  void initState() {
    super.initState();
    _speakFeature();
  }

  Future<void> _speakFeature() async {
    await tts.stop();
    if (currentIndex == 0) {
      await tts.speak(
        "Welcome to BASIRA. Swipe left to begin exploring features.",
      );
    } else {
      await tts.speak("${features[currentIndex]}. Double tap to activate.");
    }
  }

  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  void _nextFeature() {
    _vibrate();
    setState(() {
      currentIndex = (currentIndex + 1) % features.length;
    });
    _speakFeature();
  }

  void _prevFeature() {
    _vibrate();
    setState(() {
      currentIndex = (currentIndex - 1 + features.length) % features.length;
    });
    _speakFeature();
  }

  void _launchFeature() {
    _vibrate();
    switch (currentIndex) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => money.MoneyRecognitionScreen(camerass: cameras),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TextRecognitionPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => object.YoloVideo(camerass: cameras),
          ),
        );
        break;
    }
  }

  String getFeatureIconPath() {
    switch (currentIndex) {
      case 1:
        return 'assets/icons/moneyd.jpg';
      case 2:
        return 'assets/icons/textd.jpg';
      case 3:
        return 'assets/icons/objdet.jpg';
      default:
        return 'assets/icons/welcomep.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          _nextFeature();
        } else if (details.primaryVelocity! > 0) {
          _prevFeature();
        }
      },
      onDoubleTap: _launchFeature,
      onLongPress: _speakFeature,
      child: Scaffold(
        appBar: AppBar(title: const Text('BASIRA')),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color.fromARGB(255, 135, 145, 255)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 50,
                left: 69,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 135, 145, 255),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(40),
                    image: DecorationImage(
                      image: AssetImage(getFeatureIconPath()),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 380, left: 50, right: 50),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentIndex == 0
                            ? 'Welcome to BASIRA.\n\nSwipe left to begin exploring features.'
                            : 'Current: ${features[currentIndex]}\n\nSwipe left or right to change feature.\nDouble tap to activate.',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

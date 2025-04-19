//maindart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
// For YoloVideo
import 'screens/home_Screen.dart'; // Your ready-to-scan interface

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BASIRA',
      theme: ThemeData(
        primaryColor: const Color(0xFFFF7EDB),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WelcomeCenterScreen(cameras: cameras), // ✅ Launch this screen first
    );
  }
}

//1camerascreen
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'money_Screen.dart'; // or wherever your YoloVideo is

class MoneyReadyToScan extends StatelessWidget {
  const MoneyReadyToScan({super.key});

  Future<void> openCamera(BuildContext context) async {
    // Optional: show loading spinner while initializing camera
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final cameras = await availableCameras();

    Navigator.pop(context); // Close loading dialog

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => YoloVideo(camerass: cameras)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => openCamera(context), // 👈 double tap to trigger scan
      child: Scaffold(
        appBar: AppBar(title: const Text('Money recognition')),
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
                    image: const DecorationImage(
                      image: AssetImage('assets/icons/moneyd.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 30,
                  ),
                  child: const Text(
                    'Welcome to the BASIRA Money Recognition feature.\n'
                    'Double-tap anywhere on the screen to start scanning.\n'
                    'Point your back camera towards bills or coins.',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (int index) {
            // Implement page switching here
          },
          items: const [
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/icons/text.png'), size: 28),
              label: 'TEXT',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/icons/obj.png'), size: 28),
              label: 'OBJECT',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/icons/money.png'), size: 28),
              label: 'MONEY',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import your HomeScreen widget here

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: SplashScreen(),
      routes: {
        '/home': (context) => HomeScreen(), // Define your HomeScreen route
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a loading time for the splash screen
    Future.delayed(Duration(seconds: 2), () {
      // Navigate to the HomeScreen after the delay
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color for the splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ROUTINE',
              style: TextStyle(
                fontSize: 70.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier New',
                color: Colors.green, // Monospaced font
              ),
            ),
            SizedBox(height: 0.5),
            Text(
              'DEVELOPED BY SABBIR',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier New',
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

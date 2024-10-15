import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'login.dart';
import 'home.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    
    var box = Hive.box('userBox');
    bool isLoggedIn = box.get('email') != null && box.get('password') != null;

    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const ScreenLogin()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'ios/assets/IMG_1413.PNG', 
          height: 200,
        ),
      ),
    );
  }
}

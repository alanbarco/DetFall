import 'package:flutter/material.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadMainScreen();
  }

  _loadMainScreen() async {
    await Future.delayed(Duration(seconds: 3)); 
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => MyHomePage(), 
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 88, 110, 125),
      body: Center(
        child: Image.asset('./assets/images/alert_icon.png'), 
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import './formScreen.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('nombre');
    String? phone = prefs.getString('celular');

    await Future.delayed(Duration(seconds: 3)); 

    if (name != null && phone != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FormScreen()),
      );
    }
  }

  // _loadMainScreen() async {
  //   await Future.delayed(Duration(seconds: 3)); 
  //   Navigator.of(context).pushReplacement(MaterialPageRoute(
  //     builder: (context) => MyHomePage(), 
  //   ));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 225, 228, 229),
      body: Center(
        child: Image.asset('./assets/images/alert_icon.png'), 
      ),
    );
  }
}

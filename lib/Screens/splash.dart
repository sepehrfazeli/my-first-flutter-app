import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/Screens/Home.dart';
import 'package:todoapp/Screens/login.dart';

import 'package:todoapp/assets/images.dart';
import 'package:todoapp/services/shaered_pref.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? name;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    String? userName = await ShaeredPreferenceHelper().getUserName();
    setState(() {
      name = userName;
    });
    redirect();
  }

  Future<void> saveUserNameToSharedPref(String name) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('username', name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
            height: 200, width: 300, child: Image.asset(AppImages.Logo)),
      ),
    );
  }

  Future<void> redirect() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      // Check if name is null, navigate accordingly
      if (name == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const LoginPage(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const HomePage(),
          ),
        );
      }
    }
  }
}

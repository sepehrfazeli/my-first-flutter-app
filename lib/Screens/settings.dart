import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/Screens/login.dart';

import 'package:todoapp/assets/images.dart';
import 'package:todoapp/services/shaered_pref.dart';
import 'package:todoapp/theme/colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
  }

  Future<void> saveUserNameToSharedPref(String name) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('username', name);
  }

  // Logout function
  Future<void> _logout() async {
    ShaeredPreferenceHelper().clearSession();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const LoginPage()),
      (route) => false,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text(
            'Confirm Logout',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppColors.darckBackground),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.darckBackground),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darckBackground),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darckBackground),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Settings',
          style: TextStyle(
              color: AppColors.black,
              fontSize: 25,
              fontWeight: FontWeight.w500),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(AppImages.Profile),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? 'Loading...',
                      style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                    const Text(
                      'Deggendorf, Germany',
                      style: TextStyle(
                          color: AppColors.darckBackground,
                          fontSize: 15,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
                const Spacer(),
                CircleAvatar(
                    backgroundColor: AppColors.darckBackground,
                    radius: 25,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.edit,
                        size: 30,
                        color: AppColors.white,
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Text(
                  'Hi! My name is Sepehr',
                  style: TextStyle(
                      color: AppColors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                )),
            const SizedBox(height: 60),
            _settings(Icons.notifications, 'Notifications'),
            const SizedBox(height: 20),
            _settings(Icons.settings, 'General'),
            const SizedBox(height: 20),
            _settings(Icons.person, 'Account'),
            const SizedBox(height: 20),
            _settings(Icons.lightbulb_circle_sharp, 'About'),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _showLogoutDialog,
              child: _settings(Icons.exit_to_app, 'Logout'),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _settings(IconData ikon, String setting) {
    return SizedBox(
      child: Row(
        children: [
          Icon(
            ikon,
            size: 30,
            color: AppColors.darckBackground,
          ),
          const SizedBox(width: 20),
          Text(
            setting,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.darckBackground),
          )
        ],
      ),
    );
  }
}

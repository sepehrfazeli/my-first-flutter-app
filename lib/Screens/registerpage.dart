import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/Screens/Home.dart';
import 'package:todoapp/Screens/login.dart';
import 'package:todoapp/theme/colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 170),
            Row(
              children: [
                const SizedBox(width: 20),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 30),
                const Text(
                  "Create an Account",
                  style: TextStyle(
                      color: AppColors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 50),
            _textField(
              controller: fullNameController,
              hint: 'Full Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _textField(
              hint: 'Email',
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _textField(
              hint: 'Password',
              controller: passwordController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                } else if (value.length < 6) {
                  return 'Password must be at least 6 characters long';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _textField(
              hint: 'Confirm Password',
              controller: confirmPasswordController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                } else if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                onSignUp(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                width: 350,
                alignment: Alignment.center,
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account?",
                  style: TextStyle(
                      color: AppColors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const LoginPage()));
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                        color: AppColors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Material _textField({
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    required String? Function(String? value) validator,
  }) {
    return Material(
      elevation: 2.5,
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        width: 350,
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.grey, fontSize: 20),
            border: const UnderlineInputBorder(borderSide: BorderSide.none),
          ),
          validator: validator,
        ),
      ),
    );
  }

  void onSignUp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Attempt to register user
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Save user details to Firebase Firestore
        User? user = userCredential.user;

        Map<String, dynamic> userData = {
          "uid": user?.uid,
          "FullName": fullNameController.text.trim(),
          "Gmail": emailController.text.trim(),
        };

        // Save user data in Firestore
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(user?.uid)
            .set(userData);

        // Save locally in SharedPreferences
        await SharedPreferenceHelper()
            .saveUserName(fullNameController.text.trim());

        // Save user data to file
        await saveUserDataToFile(userData);

        // Display success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green[400],
            content: const Row(
              children: [
                Text("Registered successfully"),
                Icon(Icons.check_circle, color: Colors.white),
              ],
            ),
          ),
        );

        // Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        // Handle Firebase authentication errors
        String errorMessage = "";

        switch (e.code) {
          case 'email-already-in-use':
            errorMessage =
                "The email address is already in use. Please log in or use another email.";
            break;
          case 'invalid-email':
            errorMessage = "The email address entered is invalid.";
            break;
          case 'weak-password':
            errorMessage =
                "The password is too weak. Use at least 6 characters.";
            break;
          default:
            errorMessage = e.message ?? "An unknown error occurred.";
        }

        // Display error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Row(
              children: [
                Expanded(child: Text(errorMessage)),
                const Icon(Icons.error, color: Colors.white),
              ],
            ),
          ),
        );
      } catch (e) {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Row(
              children: [
                Expanded(
                    child: Text(
                        "An unexpected error occurred. Please try again.")),
                Icon(Icons.error, color: Colors.white),
              ],
            ),
          ),
        );
        print("Error during sign-up: $e");
      }
    }
  }

  Future<void> saveUserDataToFile(Map<String, dynamic> userData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/users.json';
      final file = File(filePath);

      List<dynamic> usersList = await _readUserDataFromFile(file);
      usersList.add(userData);

      await file.writeAsString(jsonEncode(usersList));
      print('User data saved to $filePath');
    } catch (e) {
      print("Failed to save user data: $e");
    }
  }

  Future<List<dynamic>> _readUserDataFromFile(File file) async {
    if (await file.exists()) {
      String content = await file.readAsString();
      return jsonDecode(content);
    }
    return [];
  }
}

class SharedPreferenceHelper {
  Future<void> saveUserName(String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', fullName);
  }
}

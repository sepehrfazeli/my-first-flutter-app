import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todoapp/Screens/Home.dart';
import 'package:todoapp/Screens/registerpage.dart';
import 'package:todoapp/assets/images.dart';
import 'package:todoapp/theme/colors.dart';
import 'package:todoapp/services/shaered_pref.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 170),
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: Image.asset(AppImages.Logo),
              ),
            ),
            _textField(
              hint: 'Email',
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            _textField(
              hint: 'Password',
              controller: passwordController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                } else if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  loginUser(context);
                }
              },
              child: Container(
                color: AppColors.blue,
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
                  "Don't have an account?",
                  style: TextStyle(
                      color: AppColors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()));
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(
                        color: AppColors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
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
    String? Function(String?)? validator,
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
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.grey, fontSize: 20),
            border: const UnderlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  void loginUser(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection("Users")
          .where("Gmail", isEqualTo: emailController.text.trim())
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        String userName = userQuery.docs.first['FullName'];

        // Save the username to SharedPreferences using ShaeredPreferenceHelper
        await ShaeredPreferenceHelper().saveUserName(userName);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green[400],
            content: const Row(
              children: [
                Text("Logged in successfully"),
                Icon(Icons.check_circle, color: Colors.white),
              ],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("No user found with this email."),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Row(
            children: [
              Expanded(child: Text(error.toString())),
              const Icon(Icons.error, color: Colors.white),
            ],
          ),
        ),
      );
    }
  }
}

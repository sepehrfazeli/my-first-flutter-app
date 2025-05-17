import 'package:flutter/material.dart';

import 'package:todoapp/Screens/registerpage.dart';
import 'package:todoapp/theme/colors.dart';

class ForgotPassWordpage extends StatefulWidget {
  const ForgotPassWordpage({super.key});

  @override
  State<ForgotPassWordpage> createState() => _ForgotPassWordpageState();
}

class _ForgotPassWordpageState extends State<ForgotPassWordpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          const SizedBox(
            height: 170,
          ),
          Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 35,
                  )),
              const SizedBox(
                width: 30,
              ),
              const Text(
                "Forgot Password",
                style: TextStyle(
                    color: AppColors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          _textField('Email'),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Enter the email address you used to create your account and\nWe will email you a link to reset your password',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.black,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            color: AppColors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
          const SizedBox(
            height: 30,
          ),
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()));
                },
                child: const Text(
                  "Register",
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
    );
  }

  Material _textField(String hint) {
    return Material(
      elevation: 2.5,
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        width: 350,
        child: TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.grey, fontSize: 20),
            border: const UnderlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }
}

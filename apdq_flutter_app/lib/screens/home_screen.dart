import 'package:apdq_flutter_app/screens/login_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEBF6F1),
        ),
        child: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: Image.asset(
              'assets/images/Logorb.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

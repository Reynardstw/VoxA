import 'package:client/page/register.dart';
import 'package:flutter/material.dart';
import 'package:client/page/login.dart';

class WelcomePage extends StatelessWidget {
  final Color primaryColor;
  final Color greyColor;

  const WelcomePage({super.key})
    : primaryColor = const Color(0xFF4B00E0),
      greyColor = const Color(0xFFE0E0E0);

  void navigateToLogin(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void navigateToRegister(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greyColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(padding: EdgeInsets.all(20)),
            const Image(image: AssetImage('images/icon.png'), width: 250),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              height: 40,
              child: ElevatedButton(
                onPressed: () => navigateToLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              height: 40,
              child: ElevatedButton(
                onPressed: () => navigateToRegister(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

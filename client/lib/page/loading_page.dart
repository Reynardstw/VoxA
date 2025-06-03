import 'dart:async';
import 'package:flutter/material.dart';
import 'home_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final List<String> texts = [
    "Artificial Intelligence untuk kamu, yang dapat meringkaskan informasi kompleks menjadi inti yang mudah dipahami.",
    "AI-mu, Ringkasanmu.",
  ];

  String displayText = '';
  int textIndex = 0;
  int charIndex = 0;
  bool isDeleting = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTyping();
  }

  void startTyping() {
    const typingSpeed = Duration(milliseconds: 35);
    const pauseDuration = Duration(seconds: 1);

    timer = Timer.periodic(typingSpeed, (Timer t) {
      setState(() {
        final fullText = texts[textIndex];

        if (!isDeleting) {
          if (charIndex < fullText.length) {
            displayText = fullText.substring(0, charIndex + 1);
            charIndex++;
          } else {
            if (textIndex == texts.length - 1) {
              timer?.cancel();
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                }
              });
            } else {
              isDeleting = true;
              timer?.cancel();
              Future.delayed(pauseDuration, startTyping);
            }
          }
        } else {
          if (charIndex > 0) {
            charIndex--;
            displayText = fullText.substring(0, charIndex);
          } else {
            isDeleting = false;
            textIndex++;
            timer?.cancel();
            Future.delayed(const Duration(milliseconds: 300), startTyping);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/voxa_cat.png', height: 200),
            const SizedBox(height: 1),

            const Text(
              "VoxA",
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 6),

            SizedBox(
              height: 65,
              child: Text(
                displayText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.indigo,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

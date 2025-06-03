import 'dart:async';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:lottie/lottie.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final List<String> texts = [
    "Input diterima. Memproses...",
    "Ringkasan sedang disiapkan.",
    "Mengoptimalkan inti informasi.",
    "Tugas selesai. Siap digunakan.", // kalimat terakhir: tidak dihapus
  ];

  double progress = 0.0;
  late Timer progressTimer;

  String displayText = '';
  int currentTextIndex = 0;

  Timer? typingTimer;
  Timer? erasingTimer;

  int typingIndex = 0;

  @override
  void initState() {
    super.initState();
    displayText = '';
    startProgress();
    startTyping();
  }

  void startProgress() {
    const totalDuration = Duration(seconds: 12);
    const tick = Duration(milliseconds: 50);
    final tickCount = totalDuration.inMilliseconds ~/ tick.inMilliseconds;
    final progressIncrement = 1.0 / tickCount;

    progressTimer = Timer.periodic(tick, (Timer t) {
      setState(() {
        progress += progressIncrement;
        if (progress >= 1.0) {
          progress = 1.0;
          progressTimer.cancel();
        }
      });
    });
  }

  void startTyping() {
    final fullText = texts[currentTextIndex];
    typingIndex = 0;
    displayText = '';

    typingTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      setState(() {
        if (typingIndex < fullText.length) {
          displayText += fullText[typingIndex];
          typingIndex++;
        } else {
          typingTimer?.cancel();

          // Jika ini kalimat terakhir, langsung ke halaman
          if (currentTextIndex == texts.length - 1) {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 600),
                    pageBuilder: (_, __, ___) => const HomePage(),
                    transitionsBuilder: (_, animation, __, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              }
            });
          } else {
            // Kalau belum terakhir, lanjut hapus dari kanan
            Future.delayed(const Duration(seconds: 1), startErasing);
          }
        }
      });
    });
  }

  void startErasing() {
    erasingTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      setState(() {
        if (displayText.isNotEmpty) {
          displayText = displayText.substring(0, displayText.length - 1);
        } else {
          erasingTimer?.cancel();
          currentTextIndex++;
          Future.delayed(const Duration(milliseconds: 300), startTyping);
        }
      });
    });
  }

  @override
  void dispose() {
    progressTimer.cancel();
    typingTimer?.cancel();
    erasingTimer?.cancel();
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
            const Text(
              "VoxA",
              style: TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),

            Lottie.asset(
              'assets/animations/voxa_cat.json',
              height: 200,
              repeat: true,
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 24,
              width: double.infinity, // biar memenuhi lebar layar
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: Text(
                  displayText,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.indigo,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                color: Colors.indigo,
                minHeight: 8,
              ),
            ),

            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

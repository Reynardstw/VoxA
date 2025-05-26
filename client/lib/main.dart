import 'package:client/page/welcome.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final Color primaryColor = const Color(0xFF4B00E0);
  final Color greyColor = const Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VoxA AI Summarizer',
      home: WelcomePage(),
    );
  }
}

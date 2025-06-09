import 'package:client/page/welcome.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SummarizerApp());
}

class SummarizerApp extends StatelessWidget {
  const SummarizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoxA',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

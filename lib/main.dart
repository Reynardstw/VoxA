import 'package:flutter/material.dart';
import 'pages/real_home.dart';

void main() {
  runApp(const SummarizerApp());
}

class SummarizerApp extends StatelessWidget {
  const SummarizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Translator',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

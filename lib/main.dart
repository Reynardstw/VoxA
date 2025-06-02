import 'package:flutter/material.dart';
import 'pages/loading_page.dart';

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
      home: LoadingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

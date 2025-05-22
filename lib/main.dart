import 'package:flutter/material.dart';
import 'pages/loading_page.dart';

void main() {
  runApp(const TranslatorApp());
}

class TranslatorApp extends StatelessWidget {
  const TranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Translator',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: LoadingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

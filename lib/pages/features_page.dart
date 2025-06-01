import 'package:flutter/material.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  Widget buildFeatureTile(String iconPath, String label, Color bgColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(iconPath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Our Features',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildFeatureTile(
              'assets/icons/summary.png',
              'Your Summary',
              Colors.pinkAccent,
            ),
            buildFeatureTile(
              'assets/icons/summarize.png',
              'Summarize from text',
              Colors.indigoAccent,
            ),
            buildFeatureTile(
              'assets/icons/audio.png',
              'Summarize from audio',
              Colors.deepOrangeAccent,
            ),
            buildFeatureTile(
              'assets/icons/translate.png',
              'Translate to other language',
              Colors.orange,
            ),
            buildFeatureTile(
              'assets/icons/record.png',
              'Live record',
              Colors.deepPurpleAccent,
            ),
          ],
        ),
      ),
    );
  }
}

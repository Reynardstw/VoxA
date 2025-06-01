import 'dart:ui';
import 'package:flutter/material.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  String selectedCountry = 'Indonesia 🇮🇩';
  final TextEditingController _controller = TextEditingController();
  String translatedText = '';

  final Map<String, String> flagImageMap = {
    'Indonesia 🇮🇩': 'assets/flags/indonesia.png',
    'United States 🇺🇸': 'assets/flags/america.png',
    'Japan 🇯🇵': 'assets/flags/japan.png',
    'France 🇫🇷': 'assets/flags/france.png',
    'Spain 🇪🇸': 'assets/flags/spain.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Image.asset(
                  flagImageMap[selectedCountry]!,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
              ),
              const Positioned.fill(
                child: Center(
                  child: Text(
                    'Get Started\n& Translate',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              onChanged: (value) {
                setState(() {
                  translatedText = "Translated: $value";
                });
              },
              decoration: const InputDecoration(
                labelText: 'Type something...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    value: selectedCountry,
                    isExpanded: true,
                    underline: Container(height: 1, color: Colors.black26),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCountry = newValue!;
                      });
                    },
                    items:
                        flagImageMap.keys.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    translatedText.isEmpty
                        ? 'Translation result will appear here...'
                        : translatedText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Center(
              child: CircleAvatar(
                backgroundColor: Colors.indigo,
                radius: 30,
                child: const Icon(Icons.mic, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

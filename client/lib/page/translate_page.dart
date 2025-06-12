import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

class TranslatePage extends StatefulWidget {
  final String textToTranslate; // menerima parameter teks

  const TranslatePage({super.key, required this.textToTranslate});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  final FlutterTts flutterTts = FlutterTts();
  late TextEditingController _controller;
  final GoogleTranslator translator = GoogleTranslator();

  String? detectedLangCode;
  String selectedCountry = 'Indonesia 🇮🇩';
  String translatedText = '';

  final Map<String, String> flagImageMap = {
    'Indonesia 🇮🇩': 'assets/flags/indonesia.png',
    'United States 🇺🇸': 'assets/flags/america.png',
    'Japan 🇯🇵': 'assets/flags/japan.png',
    'France 🇫🇷': 'assets/flags/france.png',
    'Spain 🇪🇸': 'assets/flags/spain.png',
  };

  final Map<String, String> langMap = {
    'Indonesia 🇮🇩': 'id',
    'United States 🇺🇸': 'en',
    'Japan 🇯🇵': 'ja',
    'France 🇫🇷': 'fr',
    'Spain 🇪🇸': 'es',
  };

  final Map<String, String> langIconMap = {
    'id': 'assets/flags/indonesia.png',
    'en': 'assets/flags/america.png',
    'ja': 'assets/flags/japan.png',
    'fr': 'assets/flags/france.png',
    'es': 'assets/flags/spain.png',
  };

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.textToTranslate);
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.5);

    // Langsung auto translate saat dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      autoTranslate(widget.textToTranslate);
    });
  }

  Future<void> autoTranslate(String input) async {
    if (input.trim().isEmpty) {
      setState(() {
        translatedText = '';
        detectedLangCode = null;
      });
      return;
    }

    final targetLang = langMap[selectedCountry] ?? 'en';

    try {
      final translation = await translator.translate(
        input,
        to: targetLang,
        from: 'auto',
      );

      setState(() {
        translatedText = translation.text;
        detectedLangCode = translation.sourceLanguage.code;
      });
    } catch (_) {
      setState(() {
        translatedText = 'Failed to translate.';
        detectedLangCode = null;
      });
    }
  }

  Future<void> _speakTranslatedText() async {
    if (translatedText.isNotEmpty) {
      await flutterTts.setLanguage(langMap[selectedCountry] ?? 'en');
      await flutterTts.speak(translatedText);
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoxA Translator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _controller,
                onChanged: autoTranslate,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Enter text to translate',
                  prefixIcon:
                      detectedLangCode == null
                          ? const Icon(Icons.language)
                          : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              langIconMap[detectedLangCode!] ??
                                  'assets/flags/america.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Bahasa Tujuan (Deretan Bendera)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      flagImageMap.entries.map((entry) {
                        final selected = selectedCountry == entry.key;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCountry = entry.key;
                              autoTranslate(_controller.text);
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    selected
                                        ? Colors.indigo
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                entry.value,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),

            // Hasil Terjemahan (Bahasa + Bendera + Box)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        selectedCountry == 'Indonesia 🇮🇩'
                            ? [Colors.red.shade100, Colors.white]
                            : selectedCountry == 'United States 🇺🇸'
                            ? [Colors.blue.shade100, Colors.white]
                            : selectedCountry == 'Japan 🇯🇵'
                            ? [Colors.white, Colors.red.shade100]
                            : selectedCountry == 'France 🇫🇷'
                            ? [Colors.blue.shade100, Colors.red.shade100]
                            : selectedCountry == 'Spain 🇪🇸'
                            ? [Colors.red.shade100, Colors.yellow.shade100]
                            : [Colors.grey.shade200, Colors.grey.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bahasa + bendera dalam satu baris
                    Row(
                      children: [
                        Text(
                          selectedCountry.split(' ').first,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          flagImageMap[selectedCountry]!,
                          width: 28,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Box hasil terjemahan
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              translatedText.isEmpty
                                  ? 'Translation result will appear here...'
                                  : translatedText,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                tooltip: 'Copy',
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: translatedText),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied to clipboard'),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up, size: 20),
                                tooltip: 'Speak',
                                onPressed: _speakTranslatedText,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

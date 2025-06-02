import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _controller = TextEditingController();
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
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.5);
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
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
                          'VoxA Translator',
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
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 120,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: TextField(
                          controller: _controller,
                          onChanged: autoTranslate,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
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
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD8EAFE), Color(0xFFE8E6F9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black12, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButton<String>(
                          value: selectedCountry,
                          isExpanded: true,
                          underline: Container(
                            height: 1,
                            color: Colors.black26,
                          ),
                          onChanged: (String? newValue) {
                            setState(() => selectedCountry = newValue!);
                            autoTranslate(_controller.text);
                          },
                          items:
                              flagImageMap.keys
                                  .map<DropdownMenuItem<String>>(
                                    (String value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: SingleChildScrollView(
                            child:
                                translatedText.isEmpty
                                    ? const Text(
                                      'Translation result will appear here...',
                                      style: TextStyle(fontSize: 16),
                                    )
                                    : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            translatedText,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.copy,
                                                size: 20,
                                              ),
                                              tooltip: 'Copy',
                                              onPressed: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: translatedText,
                                                  ),
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Copied to clipboard',
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.volume_up,
                                                size: 20,
                                              ),
                                              tooltip: 'Speak',
                                              onPressed: _speakTranslatedText,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: CircleAvatar(
                    backgroundColor: Colors.indigo,
                    radius: 30,
                    child: Icon(Icons.mic, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

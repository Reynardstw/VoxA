import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final translator = GoogleTranslator();
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isPaused = false;
  bool _showControlButtons = false;
  String _translatedText = '';
  String _currentLocaleId = 'en_US';
  String _selectedLanguage = 'id';
  Timer? _debounce;

  final Map<String, String> _languages = {
    'Indonesian': 'id',
    'English': 'en',
    'Spanish': 'es',
    'French': 'fr',
    'Japanese': 'ja',
  };

  Future<String> summarizeText(String text) async {
    const apiKey = 'API_KEY';

    final response = await http.post(
      Uri.parse(
        'https://api-inference.huggingface.co/models/facebook/bart-large-cnn',
      ),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"inputs": text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty && data[0]['summary_text'] != null) {
        return data[0]['summary_text'];
      } else {
        return "Ringkasan tidak tersedia.";
      }
    } else {
      print('HuggingFace error: ${response.body}');
      throw Exception('Gagal meringkas: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () async {
      if (text.trim().isEmpty) {
        setState(() => _translatedText = '');
        return;
      }

      final translation = await translator.translate(
        text,
        to: _selectedLanguage,
      );
      setState(() => _translatedText = translation.text);
    });
  }

  Future<void> _speakTranslatedText() async {
    if (_translatedText.isNotEmpty) {
      await _flutterTts.setLanguage(_selectedLanguage);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(_translatedText);
    }
  }

  Future<void> _startListeningWithLocale(String localeId) async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('STATUS: $status'),
      onError: (error) => print('ERROR: $error'),
    );

    if (available) {
      setState(() {
        _isListening = true;
        _isPaused = false;
        _showControlButtons = true;
        _currentLocaleId = localeId;
      });

      await _speech.listen(
        localeId: localeId,
        listenFor: Duration(hours: 1),
        pauseFor: Duration(hours: 1),
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
            _onTextChanged(result.recognizedWords);
          });
        },
      );
    }
  }

  Future<void> _pauseListening() async {
    await _speech.stop();
    setState(() {
      _isPaused = true;
      _isListening = false;
    });
  }

  Future<void> _resumeListening(String localeId) async {
    setState(() {
      _isPaused = false;
      _isListening = true;
    });

    await _speech.listen(
      localeId: localeId,
      listenFor: Duration(hours: 1),
      pauseFor: Duration(hours: 1),
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
          _onTextChanged(result.recognizedWords);
        });
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _isPaused = false;
      _showControlButtons = false;
    });
  }

  void _showLocalePicker(BuildContext context, List<stt.LocaleName> locales) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ListView.builder(
          itemCount: locales.length,
          itemBuilder: (_, index) {
            final locale = locales[index];
            return ListTile(
              title: Text(locale.name ?? locale.localeId),
              onTap: () {
                Navigator.pop(context);
                _startListeningWithLocale(locale.localeId);
              },
            );
          },
        );
      },
    );
  }

  void _showAudioOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.file_upload),
                title: Text('Import file audio'),
                onTap: () async {
                  Navigator.pop(context);
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['mp3', 'wav', 'm4a'],
                      );
                  if (result != null) {
                    String? filePath = result.files.single.path;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('File dipilih: $filePath')),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.mic),
                title: Text('Rekam suara'),
                onTap: () async {
                  Navigator.pop(context);
                  List<stt.LocaleName> locales = await _speech.locales();
                  _showLocalePicker(context, locales);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButtons() {
    if (!_showControlButtons) return SizedBox.shrink();

    return Positioned(
      bottom: 150,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            label: Text(_isPaused ? 'Lanjutkan' : 'Jeda'),
            onPressed: () {
              if (_isPaused) {
                _resumeListening(_currentLocaleId);
              } else {
                _pauseListening();
              }
            },
          ),
          SizedBox(width: 16),
          ElevatedButton.icon(
            icon: Icon(Icons.stop),
            label: Text('Stop'),
            onPressed: _stopListening,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAudioOptions(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        tooltip: 'Pilih input audio',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: Icon(Icons.home), onPressed: () {}),
              IconButton(icon: Icon(Icons.folder), onPressed: () {}),
              SizedBox(width: 40),
              IconButton(icon: Icon(Icons.remove_red_eye), onPressed: () {}),
              IconButton(icon: Icon(Icons.person), onPressed: () {}),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 60, bottom: 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 3, 143, 236),
                      const Color.fromARGB(255, 137, 187, 233),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.language, color: Colors.yellow, size: 32),
                    SizedBox(height: 10),
                    Text(
                      'Realtime Translator',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Translate anything instantly',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From (Auto Detect)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _controller,
                              onChanged: _onTextChanged,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Type or speak your text...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          border: Border.all(color: Colors.indigo.shade100),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedLanguage,
                              decoration: InputDecoration(
                                labelText: 'To',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items:
                                  _languages.entries.map((entry) {
                                    return DropdownMenuItem(
                                      value: entry.value,
                                      child: Text(entry.key),
                                    );
                                  }).toList(),
                              onChanged:
                                  (val) =>
                                      setState(() => _selectedLanguage = val!),
                            ),
                            SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _translatedText.isEmpty
                                          ? 'Translation will appear here...'
                                          : _translatedText,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.volume_up),
                                    onPressed: _speakTranslatedText,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            if (_translatedText.isNotEmpty)
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final summary = await summarizeText(
                                    _translatedText,
                                  );
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: Text("Ringkasan"),
                                          content: Text(summary),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: Text("Tutup"),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                                icon: Icon(Icons.summarize),
                                label: Text("Ringkas"),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildControlButtons(),
        ],
      ),
    );
  }
}

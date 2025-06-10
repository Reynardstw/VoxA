import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SummaryPage extends StatefulWidget {
  final String? transcribedText;

  const SummaryPage({super.key, this.transcribedText});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _controller = TextEditingController();
  String _summary = '';
  bool _isSummarizing = false;
  String? token;

  @override
  void initState() {
    super.initState();
    flutterTts.setSpeechRate(0.5);
    flutterTts.setPitch(1.0);

    if (widget.transcribedText != null) {
      _controller.text = widget.transcribedText!;
    }
  }

  Future<bool> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedToken = prefs.getString('token');
    if (storedToken == null) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token not found. Please log in again.')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
      return false;
    }
    setState(() {
      token = storedToken;
    });
    return true;
  }

  Future<String> summarizeText(String text) async {
    final apiKey = dotenv.env['HUGGINGFACE_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key dari .env tidak ditemukan');
    }

    final response = await http.post(
      Uri.parse(
        'https://router.huggingface.co/hf-inference/models/sshleifer/distilbart-cnn-12-6',
      ),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"inputs": text}),
    );

    print("Status code: ${response.statusCode}");
    print("Body: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty && data[0]['summary_text'] != null) {
        setState(() {
          _summary = data[0]['summary_text'];
        });
        await _storeSummary(_summary);
        if (!mounted) return _summary;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ringkasan berhasil disimpan.")),
        );
        return data[0]['summary_text'];
      } else {
        return "Ringkasan tidak tersedia.";
      }
    } else {
      if (!mounted) return "Gagal meringkas.";
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal meringkas. Coba lagi.")),
      );
      throw Exception('Gagal meringkas: ${response.statusCode}');
    }
  }

  Future<void> _storeSummary(String summary) async {
    final tokenRetrieved = await _getToken();
    if (!tokenRetrieved) return;
    if (summary.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ringkasan masih kosong.")));
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/summary/'),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'title': 'Summary', 'content': summary}),
      );
      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ringkasan berhasil disimpan.")),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Gagal menyimpan ringkasan: ${response.reasonPhrase}",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan ringkasan.")),
      );
    }
  }

  Future<void> _speakSummary() async {
    if (_summary.trim().isEmpty) return;
    await flutterTts.setLanguage("id-ID");
    await flutterTts.speak(_summary.trim());
  }

  Future<void> _copySummary() async {
    if (_summary.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _summary));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ringkasan disalin ke clipboard")),
    );
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
      appBar: AppBar(title: const Text("Ringkasan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Masukkan atau ubah teks:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Tulis teks transkripsi di sini...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed:
                  _isSummarizing
                      ? null
                      : () async {
                        final inputText = _controller.text.trim();
                        if (inputText.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Teks masih kosong.")),
                          );
                          return;
                        }

                        setState(() {
                          _isSummarizing = true;
                          _summary = "Ringkasan sedang diproses...";
                        });

                        try {
                          final summary = await summarizeText(inputText);
                          setState(() {
                            _summary = summary;
                          });
                        } catch (e) {
                          setState(() {
                            _summary = "Terjadi kesalahan saat meringkas.";
                          });
                        } finally {
                          setState(() {
                            _isSummarizing = false;
                          });
                        }
                      },
              icon:
                  _isSummarizing
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.summarize),
              label: Text(_isSummarizing ? "Memproses..." : "Ringkas"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Ringkasan Otomatis:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_summary.isEmpty ? "-" : _summary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _copySummary,
                  icon: const Icon(Icons.copy),
                  label: const Text("Salin Ringkasan"),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _speakSummary,
                  icon: const Icon(Icons.volume_up),
                  label: const Text("TTS Ringkasan"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

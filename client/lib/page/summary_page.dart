import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

  @override
  void initState() {
    super.initState();
    flutterTts.setSpeechRate(0.5);
    flutterTts.setPitch(1.0);

    if (widget.transcribedText != null) {
      _controller.text = widget.transcribedText!;
      _generateSummary();
    }
  }

  void _generateSummary() {
    String text = _controller.text.trim();
    setState(() {
      _summary = text.length > 20 ? "${text.substring(0, 20)}..." : text;
    });
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
              onChanged: (_) => _generateSummary(),
              decoration: const InputDecoration(
                hintText: "Tulis teks transkripsi di sini...",
                border: OutlineInputBorder(),
              ),
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

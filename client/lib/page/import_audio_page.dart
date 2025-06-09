import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'summary_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImportAudioPage extends StatefulWidget {
  const ImportAudioPage({super.key});

  @override
  State<ImportAudioPage> createState() => _ImportAudioPageState();
}

class _ImportAudioPageState extends State<ImportAudioPage> {
  bool _isProcessing = false;

  Future<String> transcribeAudio(String filePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://Reynardstw-whisper-transcriber.hf.space/transcribe'),
    );

    final apiKey = dotenv.env['WHISPER_API_KEY'] ?? '';
    if (apiKey.isNotEmpty) {
      request.headers['Authorization'] = apiKey;
    }

    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['text'] ?? 'Transkripsi kosong.';
    } else {
      print('Whisper API error: ${response.body}');
      return 'Gagal transkripsi.';
    }
  }

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      File audioFile = File(result.files.single.path!);

      setState(() => _isProcessing = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proses transkripsi dimulai...')),
      );

      final transcribedText = await transcribeAudio(audioFile.path);

      setState(() => _isProcessing = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryPage(transcribedText: transcribedText),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Import Audio")),
      body: Center(
        child:
            _isProcessing
                ? Lottie.asset('assets/animations/loading.json', width: 150)
                : ElevatedButton(
                  onPressed: _pickAudioFile,
                  child: const Text("Import Audio File"),
                ),
      ),
    );
  }
}

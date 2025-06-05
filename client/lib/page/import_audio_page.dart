import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lottie/lottie.dart';
import 'summary_page.dart';

class ImportAudioPage extends StatefulWidget {
  const ImportAudioPage({super.key});

  @override
  State<ImportAudioPage> createState() => _ImportAudioPageState();
}

class _ImportAudioPageState extends State<ImportAudioPage> {
  bool _isProcessing = false;

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      File audioFile = File(result.files.single.path!);
      setState(() => _isProcessing = true);

      // Simulasi proses transkripsi (ganti dengan proses asli)
      await Future.delayed(const Duration(seconds: 3));
      String transcribedText =
          "Ini hasil transkripsi suara kamu."; // Ganti dengan hasil nyata

      setState(() => _isProcessing = false);

      // Pindah ke halaman ringkasan
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

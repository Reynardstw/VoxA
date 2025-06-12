import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'summary_page.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  Duration _duration = Duration.zero;
  Timer? _timer;
  bool isRecording = false;
  bool _isProcessing = false;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initPlayer();
  }

  Future<void> _initRecorder() async {
    try {
      await Permission.microphone.request();

      final dir = await getTemporaryDirectory();
      _filePath = '${dir.path}/recorded_audio.aac';

      await _recorder.openRecorder();
      _isRecorderInitialized = true;
      setState(() {});
    } catch (_) {}
  }

  Future<void> _initPlayer() async {
    await _player.openPlayer();
    _isPlayerInitialized = true;
    setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration += const Duration(seconds: 1);
      });
    });
  }

  void _startRecording() async {
    if (!_isRecorderInitialized) return;

    try {
      await _recorder.startRecorder(toFile: _filePath, codec: Codec.aacADTS);

      setState(() {
        isRecording = true;
        _duration = Duration.zero;
      });
      _startTimer();
    } catch (_) {}
  }

  void _pauseTimer() {
    setState(() {
      isRecording = false;
    });
    _timer?.cancel();
  }

  void _resumeTimer() {
    setState(() {
      isRecording = true;
    });
    _startTimer();
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    await _recorder.stopRecorder();
    setState(() {
      isRecording = false;
    });

    if (_filePath != null) {
      final fileSize = File(_filePath!).lengthSync();

      if (fileSize < 5000) return;

      setState(() => _isProcessing = true);

      final text = await transcribeAudio(_filePath!);

      setState(() => _isProcessing = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryPage(transcribedText: text),
        ),
      );
    }
  }

  Future<String> transcribeAudio(String filePath) async {
    try {
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
        return 'Gagal transkripsi.';
      }
    } catch (_) {
      return 'Terjadi kesalahan.';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            SizedBox(
              height: 120,
              width: 120,
              child:
                  isRecording
                      ? Lottie.asset('assets/animations/mic.json')
                      : Image.asset('assets/icons/mic_record.png'),
            ),
            const SizedBox(height: 12),
            Text(
              _formatDuration(_duration),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 48),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Gelombang suara (placeholder)",
                  style: TextStyle(color: Colors.indigo),
                ),
              ),
            ),
            const Spacer(),
            if (_isProcessing)
              Lottie.asset('assets/animations/loading.json', width: 120)
            else ...[
              IconButton(
                icon: Icon(
                  isRecording ? Icons.pause_circle : Icons.play_circle,
                  size: 64,
                  color: Colors.indigo,
                ),
                onPressed:
                    (!_isRecorderInitialized || _isProcessing)
                        ? null
                        : () {
                          if (_duration == Duration.zero && !isRecording) {
                            _startRecording();
                          } else if (isRecording) {
                            _pauseTimer();
                          } else {
                            _resumeTimer();
                          }
                        },
              ),
              ElevatedButton.icon(
                onPressed:
                    (!_isRecorderInitialized || _isProcessing)
                        ? null
                        : _stopRecording,
                icon: const Icon(Icons.stop),
                label: const Text("Stop Recording"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

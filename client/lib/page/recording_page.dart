import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  Duration _duration = Duration.zero;
  Timer? _timer;
  bool isRecording = false;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration += const Duration(seconds: 1);
      });
    });
  }

  void _startRecording() {
    setState(() {
      isRecording = true;
    });
    _startTimer();
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

  void _stopRecording() {
    _timer?.cancel();
    // TODO: implement save logic
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

            //Waveform (belum ada)
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

            IconButton(
              icon: Icon(
                isRecording ? Icons.pause_circle : Icons.play_circle,
                size: 64,
                color: Colors.indigo,
              ),
              onPressed: () {
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
              onPressed: _stopRecording,
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

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

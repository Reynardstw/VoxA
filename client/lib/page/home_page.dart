import 'dart:convert';

import 'package:client/model/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'translate_page.dart';
import 'features_page.dart';
import 'recording_page.dart';
import 'import_audio_page.dart';
import 'summary_page.dart';
import 'history.dart';
import 'package:client/model/history_count.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _totalSummaries = 0;
  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  User? _user;
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchTotalSummaries();
  }

  Future<void> _fetchTotalSummaries() async {
    final count = await SummaryService.fetchTotalSummaries();
    setState(() {
      _totalSummaries = count;
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString("user");

    User loadedUser;

    if (userJson != null && userJson.isNotEmpty && userJson != 'null') {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      loadedUser = User.fromJson(userMap);
    } else {
      loadedUser = User(
        id: 0,
        name: 'Guest',
        email: '',
        profileUrl: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    if (mounted) {
      setState(() {
        _user = loadedUser;
      });
    }
  }

  Widget buildFeatureCard({
    required String title,
    required String description,
    required String iconPath,
    required Color gradientStart,
    required Color gradientEnd,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset(
                  iconPath,
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          "${_user?.name ?? 'Guest'} 👋",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            _user?.profileUrl ??
                                'https://via.placeholder.com/150',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () => navigateTo(context, const RecordingPage()),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Record",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "your activity now",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Our AI can listen to your meeting, lectures, and so many more...",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          'assets/icons/record.png',
                          width: 40,
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Highlights",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => navigateTo(context, const FeaturesPage()),
                      child: const Text(
                        "View more",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1 / 1.3,
                  children: [
                    buildFeatureCard(
                      title: 'Your Summary',
                      description:
                          _totalSummaries == 0
                              ? 'Belum ada summary yang dibuat.'
                              : '$_totalSummaries summaries have been made...',
                      iconPath: 'assets/icons/summary.png',
                      gradientStart: Colors.pink.shade100,
                      gradientEnd: Colors.purple.shade100,
                      onTap: () => navigateTo(context, const HistoryPage()),
                    ),
                    buildFeatureCard(
                      title: 'Summarize from Text',
                      description: 'Paste your text and get full summary.',
                      iconPath: 'assets/icons/summarize.png',
                      gradientStart: Colors.orange.shade100,
                      gradientEnd: Colors.yellow.shade100,
                      onTap:
                          () => navigateTo(
                            context,
                            const SummaryPage(
                              transcribedText: "Isi teks untuk disummarize",
                            ),
                          ),
                    ),
                    buildFeatureCard(
                      title: 'Summarize from Audio',
                      description:
                          'Upload your audio and let us work the magic.',
                      iconPath: 'assets/icons/audio.png',
                      gradientStart: Colors.pink.shade200,
                      gradientEnd: Colors.red.shade100,
                      onTap: () => navigateTo(context, const ImportAudioPage()),
                    ),
                    buildFeatureCard(
                      title: 'Translate to other languages',
                      description: 'We are ready to translate it for you.',
                      iconPath: 'assets/icons/translate.png',
                      gradientStart: Colors.blue.shade100,
                      gradientEnd: Colors.purple.shade100,
                      onTap:
                          () => navigateTo(
                            context,
                            const TranslatePage(textToTranslate: ''),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

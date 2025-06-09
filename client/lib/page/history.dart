import 'dart:convert';

import 'package:client/model/summary.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Summary> summaries = [];
  bool isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    fetchSummaries();
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

  Future<void> fetchSummaries() async {
    final tokenRetrieved = await _getToken();
    if (!tokenRetrieved) return;
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/summary/'),
      headers: {
        'Authorization': 'Bearer ${token ?? ''}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];

      setState(() {
        summaries = data.map((item) => Summary.fromJson(item)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching summaries: ${response.reasonPhrase}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Summary History')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : summaries.isEmpty
              ? const Center(child: Text('No history'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: summaries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final summary = summaries[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
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
                        Text(
                          'Judul: ${summary.title}',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ringkasan:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(summary.content),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}

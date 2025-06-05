import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data riwayat untuk contoh layout
    final List<Map<String, String>> historyList = [
      {'testing': 'testing', 'hasil': 'Ini adalah hasil...'},
      {'testing': 'testing', 'hasil': 'Contoh kedua trans...'},
      {'testing': 'testing', 'hasil': 'Audio meeting tan...'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Summary History')),
      body:
          historyList.isEmpty
              ? const Center(child: Text('No history'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: historyList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = historyList[index];
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
                        const Text(
                          'Transkripsi:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(item['original'] ?? '-'),
                        const SizedBox(height: 8),
                        const Text(
                          'Ringkasan:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(item['summary'] ?? '-'),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}

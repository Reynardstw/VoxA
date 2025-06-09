class Summary {
  final int summaryId;
  final int userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Summary({
    required this.summaryId,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      summaryId: json['summaryid'],
      userId: json['userid'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdat']),
      updatedAt: DateTime.parse(json['updatedat']),
    );
  }
}

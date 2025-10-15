class Metric {
  final int id;
  final String userId;
  final String date; // ISO date
  final double? weight;
  final double? bodyFat;
  final String? photoUrl;
  final String? note;
  Metric({required this.id, required this.userId, required this.date, this.weight, this.bodyFat, this.photoUrl, this.note});
  factory Metric.fromJson(Map<String, dynamic> j) => Metric(
        id: j['id'] as int,
        userId: (j['user_id'] ?? '') as String,
        date: (j['date'] ?? '') as String,
        weight: (j['weight'] is num) ? (j['weight'] as num).toDouble() : null,
        bodyFat: (j['body_fat'] is num) ? (j['body_fat'] as num).toDouble() : null,
        photoUrl: j['photo_url'] as String?,
        note: j['note'] as String?,
      );
}


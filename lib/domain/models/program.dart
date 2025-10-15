class Program {
  final int id;
  final String title;
  final String description;
  final String? bannerUrl;
  final bool? member;
  Program({required this.id, required this.title, required this.description, this.bannerUrl, this.member});

  factory Program.fromJson(Map<String, dynamic> j) => Program(
        id: j['id'] as int,
        title: (j['title'] ?? '') as String,
        description: (j['description'] ?? '') as String,
        bannerUrl: j['banner_url'] as String?,
        member: j['member'] as bool?,
      );
}

class PostItem {
  final int id;
  final String userId;
  final int programId;
  final String? message;
  final String? photoUrl;
  final String visibility;
  final String? createdAt;
  PostItem({required this.id, required this.userId, required this.programId, this.message, this.photoUrl, required this.visibility, this.createdAt});
  factory PostItem.fromJson(Map<String, dynamic> j) => PostItem(
        id: j['id'] as int,
        userId: (j['user_id'] ?? '') as String,
        programId: j['program_id'] as int,
        message: j['message'] as String?,
        photoUrl: j['photo_url'] as String?,
        visibility: (j['visibility'] ?? 'public') as String,
        createdAt: j['created_at'] as String?,
      );
}


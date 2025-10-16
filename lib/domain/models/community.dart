import 'package:alphagrit/domain/models/profile.dart';

/// Enhanced Post model with community features
class CommunityPost {
  final int id;
  final String userId;
  final int programId;
  final String? title;
  final String? message;
  final String? photoUrl;
  final String visibility;
  final int likesCount;
  final int commentsCount;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Joined data
  final UserProfile? author;
  final bool? isLikedByCurrentUser;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.programId,
    this.title,
    this.message,
    this.photoUrl,
    required this.visibility,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isPinned = false,
    required this.createdAt,
    this.updatedAt,
    this.author,
    this.isLikedByCurrentUser,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      programId: json['program_id'] as int,
      title: json['title'] as String?,
      message: json['message'] as String?,
      photoUrl: json['photo_url'] as String?,
      visibility: json['visibility'] as String? ?? 'public',
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isPinned: json['is_pinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      author: json['author'] != null
          ? UserProfile.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      isLikedByCurrentUser: json['is_liked_by_current_user'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'program_id': programId,
      'title': title,
      'message': message,
      'photo_url': photoUrl,
      'visibility': visibility,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_pinned': isPinned,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CommunityPost copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLikedByCurrentUser,
  }) {
    return CommunityPost(
      id: id,
      userId: userId,
      programId: programId,
      title: title,
      message: message,
      photoUrl: photoUrl,
      visibility: visibility,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isPinned: isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt,
      author: author,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }
}

/// Comment model with nested replies support
class CommunityComment {
  final int id;
  final int postId;
  final String userId;
  final String content;
  final int? parentCommentId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Joined data
  final UserProfile? author;
  final List<CommunityComment>? replies;

  CommunityComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentCommentId,
    required this.createdAt,
    this.updatedAt,
    this.author,
    this.replies,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      parentCommentId: json['parent_comment_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      author: json['author'] != null
          ? UserProfile.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((r) => CommunityComment.fromJson(r as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'parent_comment_id': parentCommentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Like model
class CommunityLike {
  final int id;
  final int postId;
  final String userId;
  final DateTime createdAt;

  CommunityLike({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  factory CommunityLike.fromJson(Map<String, dynamic> json) {
    return CommunityLike(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

import 'dart:io';
import 'package:alphagrit/domain/models/community.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class CommunityRepository {
  final SupabaseClient _supabase;

  CommunityRepository(this._supabase);

  // ============================================
  // Posts
  // ============================================

  /// Get posts for a program with real-time updates
  Stream<List<CommunityPost>> watchPosts({
    required int programId,
    int limit = 50,
  }) {
    return _supabase
        .from('posts')
        .stream(primaryKey: ['id'])
        .eq('program_id', programId)
        .map((data) => data
            .where((json) => json['visibility'] == 'public')
            .map((json) => CommunityPost.fromJson(json))
            .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  /// Get a single post with author details
  Future<CommunityPost> getPost(int postId) async {
    final response = await _supabase
        .from('posts')
        .select('''
          *,
          author:user_profiles!posts_user_id_fkey(user_id, name, avatar_url)
        ''')
        .eq('id', postId)
        .single();

    return CommunityPost.fromJson(response);
  }

  /// Create a new post
  Future<CommunityPost> createPost({
    required int programId,
    String? title,
    String? message,
    String? photoUrl,
    String visibility = 'public',
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('posts')
        .insert({
          'user_id': userId,
          'program_id': programId,
          'title': title,
          'message': message,
          'photo_url': photoUrl,
          'visibility': visibility,
        })
        .select()
        .single();

    return CommunityPost.fromJson(response);
  }

  /// Update a post
  Future<CommunityPost> updatePost({
    required int postId,
    String? title,
    String? message,
  }) async {
    final response = await _supabase
        .from('posts')
        .update({
          if (title != null) 'title': title,
          if (message != null) 'message': message,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', postId)
        .select()
        .single();

    return CommunityPost.fromJson(response);
  }

  /// Delete a post
  Future<void> deletePost(int postId) async {
    await _supabase.from('posts').delete().eq('id', postId);
  }

  // ============================================
  // Comments
  // ============================================

  /// Get comments for a post with real-time updates
  Stream<List<CommunityComment>> watchComments({
    required int postId,
    int limit = 100,
  }) {
    return _supabase
        .from('community_comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .map((data) => data
            .map((json) => CommunityComment.fromJson(json))
            .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt)));
  }

  /// Create a new comment
  Future<CommunityComment> createComment({
    required int postId,
    required String content,
    int? parentCommentId,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('community_comments')
        .insert({
          'post_id': postId,
          'user_id': userId,
          'content': content,
          if (parentCommentId != null) 'parent_comment_id': parentCommentId,
        })
        .select()
        .single();

    return CommunityComment.fromJson(response);
  }

  /// Update a comment
  Future<CommunityComment> updateComment({
    required int commentId,
    required String content,
  }) async {
    final response = await _supabase
        .from('community_comments')
        .update({
          'content': content,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', commentId)
        .select()
        .single();

    return CommunityComment.fromJson(response);
  }

  /// Delete a comment
  Future<void> deleteComment(int commentId) async {
    await _supabase.from('community_comments').delete().eq('id', commentId);
  }

  // ============================================
  // Likes
  // ============================================

  /// Check if current user liked a post
  Future<bool> isPostLiked(int postId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _supabase
        .from('community_likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    return response != null;
  }

  /// Toggle like on a post
  Future<bool> toggleLike(int postId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Check if already liked
    final existing = await _supabase
        .from('community_likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      // Unlike
      await _supabase
          .from('community_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
      return false;
    } else {
      // Like
      await _supabase.from('community_likes').insert({
        'post_id': postId,
        'user_id': userId,
      });
      return true;
    }
  }

  // ============================================
  // Image Upload
  // ============================================

  /// Upload an image to Supabase Storage
  Future<String> uploadImage({
    required XFile imageFile,
    required String folder,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final bytes = await imageFile.readAsBytes();
    final fileExt = imageFile.name.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = 'community/$userId/$folder/$fileName';

    await _supabase.storage.from('community').uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

    final publicUrl = _supabase.storage.from('community').getPublicUrl(filePath);
    return publicUrl;
  }

  /// Delete an image from Supabase Storage
  Future<void> deleteImage(String imageUrl) async {
    // Extract path from public URL
    final uri = Uri.parse(imageUrl);
    final pathSegments = uri.pathSegments;

    // Find 'community' bucket and get path after it
    final bucketIndex = pathSegments.indexOf('community');
    if (bucketIndex == -1 || bucketIndex == pathSegments.length - 1) {
      throw Exception('Invalid image URL format');
    }

    final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

    await _supabase.storage.from('community').remove([filePath]);
  }

  // ============================================
  // User Access
  // ============================================

  /// Check if user has access to a program
  Future<bool> hasAccessToProgram(int programId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _supabase
        .from('user_programs')
        .select()
        .eq('user_id', userId)
        .eq('program_id', programId)
        .maybeSingle();

    return response != null;
  }

  /// Get Winter Arc program details
  Future<Map<String, dynamic>?> getWinterArcProgram() async {
    final response = await _supabase
        .from('programs')
        .select()
        .eq('slug', 'winter-arc')
        .maybeSingle();

    return response;
  }
}

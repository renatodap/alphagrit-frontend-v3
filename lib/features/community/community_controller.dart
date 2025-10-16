import 'package:alphagrit/data/repositories/community_repository.dart';
import 'package:alphagrit/domain/models/community.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

// Provider for CommunityRepository
final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository(Supabase.instance.client);
});

// Provider for Winter Arc program ID
final winterArcProgramIdProvider = FutureProvider<int?>((ref) async {
  final repo = ref.watch(communityRepositoryProvider);
  final program = await repo.getWinterArcProgram();
  return program?['id'] as int?;
});

// ============================================
// Posts Stream Provider
// ============================================

final communityPostsProvider = StreamProvider.family<List<CommunityPost>, int>((ref, programId) {
  final repo = ref.watch(communityRepositoryProvider);
  return repo.watchPosts(programId: programId);
});

// ============================================
// Comments Stream Provider
// ============================================

final postCommentsProvider = StreamProvider.family<List<CommunityComment>, int>((ref, postId) {
  final repo = ref.watch(communityRepositoryProvider);
  return repo.watchComments(postId: postId);
});

// ============================================
// Post Detail Provider (single post with author)
// ============================================

final postDetailProvider = FutureProvider.family<CommunityPost, int>((ref, postId) async {
  final repo = ref.watch(communityRepositoryProvider);
  return await repo.getPost(postId);
});

// ============================================
// Community Feed Controller
// ============================================

class CommunityFeedController extends StateNotifier<AsyncValue<void>> {
  final CommunityRepository _repository;
  final int programId;

  CommunityFeedController(this._repository, this.programId) : super(const AsyncValue.data(null));

  /// Create a new post
  Future<void> createPost({
    String? title,
    String? message,
    String? photoUrl,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createPost(
        programId: programId,
        title: title,
        message: message,
        photoUrl: photoUrl,
      );
    });
  }

  /// Toggle like on a post
  Future<bool> toggleLike(int postId) async {
    return await _repository.toggleLike(postId);
  }

  /// Upload an image
  Future<String> uploadImage(XFile imageFile) async {
    return await _repository.uploadImage(
      imageFile: imageFile,
      folder: 'posts',
    );
  }
}

final communityFeedControllerProvider =
    StateNotifierProvider.family<CommunityFeedController, AsyncValue<void>, int>((ref, programId) {
  final repository = ref.watch(communityRepositoryProvider);
  return CommunityFeedController(repository, programId);
});

// ============================================
// Post Comments Controller
// ============================================

class PostCommentsController extends StateNotifier<AsyncValue<void>> {
  final CommunityRepository _repository;
  final int postId;

  PostCommentsController(this._repository, this.postId) : super(const AsyncValue.data(null));

  /// Add a comment to the post
  Future<void> addComment({
    required String content,
    int? parentCommentId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createComment(
        postId: postId,
        content: content,
        parentCommentId: parentCommentId,
      );
    });
  }

  /// Delete a comment
  Future<void> deleteComment(int commentId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteComment(commentId);
    });
  }
}

final postCommentsControllerProvider =
    StateNotifierProvider.family<PostCommentsController, AsyncValue<void>, int>((ref, postId) {
  final repository = ref.watch(communityRepositoryProvider);
  return PostCommentsController(repository, postId);
});

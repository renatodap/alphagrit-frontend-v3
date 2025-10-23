import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:alphagrit/app/theme/theme.dart';
import 'package:alphagrit/features/community/community_controller.dart';
import 'package:alphagrit/domain/models/community.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final int postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isPostLiked = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike(int postId) async {
    try {
      final repo = ref.read(communityRepositoryProvider);
      final newLikeState = await repo.toggleLike(postId);
      setState(() {
        _isPostLiked = newLikeState;
      });
      // Refresh post to update like count
      ref.invalidate(postDetailProvider(postId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to like post: $e'),
            backgroundColor: GritColors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final controller = ref.read(postCommentsControllerProvider(widget.postId).notifier);
      await controller.addComment(content: _commentController.text.trim());
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post comment: $e'),
            backgroundColor: GritColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postDetailProvider(widget.postId));
    final commentsAsync = ref.watch(postCommentsProvider(widget.postId));

    return Scaffold(
      backgroundColor: GritColors.black,
      appBar: AppBar(
        title: const Text(
          'POST',
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Post Content
                SliverToBoxAdapter(
                  child: postAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(64.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                    ),
                    error: (error, stack) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Error loading post: $error',
                        style: TextStyle(color: GritColors.red),
                      ),
                    ),
                    data: (post) => _PostContent(
                      post: post,
                      isLiked: _isPostLiked,
                      onLikeTap: () => _toggleLike(post.id),
                    ),
                  ),
                ),

                // Comments Header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C34).withOpacity(0.3),
                      border: const Border(
                        top: BorderSide(
                          color: Color(0xFF4A4A52),
                          width: 2,
                        ),
                      ),
                    ),
                    child: commentsAsync.when(
                      loading: () => const Text(
                        'LOADING COMMENTS...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      error: (_, __) => const Text(
                        'COMMENTS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      data: (comments) => Text(
                        '${comments.length} ${comments.length == 1 ? 'COMMENT' : 'COMMENTS'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // Comments List
                commentsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                    ),
                  ),
                  error: (error, stack) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Error loading comments: $error',
                        style: TextStyle(color: GritColors.red),
                      ),
                    ),
                  ),
                  data: (comments) {
                    if (comments.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.comment_outlined,
                                size: 48,
                                color: GritColors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No comments yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: GritColors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Be the first to comment!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: GritColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _CommentCard(comment: comments[index]);
                        },
                        childCount: comments.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Comment Input
          _CommentInput(
            controller: _commentController,
            onSubmit: _submitComment,
          ),
        ],
      ),
    );
  }
}

class _PostContent extends StatelessWidget {
  final CommunityPost post;
  final bool isLiked;
  final VoidCallback onLikeTap;

  const _PostContent({
    required this.post,
    required this.isLiked,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C34),
        border: Border.all(
          color: const Color(0xFF4A4A52),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF4A90E2),
                  backgroundImage: post.author?.avatarUrl != null
                      ? NetworkImage(post.author!.avatarUrl!)
                      : null,
                  child: post.author?.avatarUrl == null
                      ? Text(
                          (post.author?.name?.substring(0, 1) ?? '?').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF000000),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.author?.name?.toUpperCase() ?? 'ANONYMOUS',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Premium badge
                          if (post.author?.winterArcTier == 'premium') ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Text(
                                'PREMIUM',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeago.format(post.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: GritColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Title
          if (post.title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.title!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  height: 1.3,
                ),
              ),
            ),

          // Message
          if (post.message != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                post.message!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFE0E0E0),
                  height: 1.6,
                ),
              ),
            ),

          // Image
          if (post.photoUrl != null)
            Image.network(
              post.photoUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

          // Like & Comment Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Like Button
                GestureDetector(
                  onTap: onLikeTap,
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 24,
                        color: isLiked ? GritColors.red : const Color(0xFF4A90E2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        post.likesCount.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),

                // Comment Count
                Row(
                  children: [
                    const Icon(
                      Icons.comment,
                      size: 24,
                      color: Color(0xFF4A90E2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.commentsCount.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final CommunityComment comment;

  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF4A4A52),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF4A90E2),
            backgroundImage: comment.author?.avatarUrl != null
                ? NetworkImage(comment.author!.avatarUrl!)
                : null,
            child: comment.author?.avatarUrl == null
                ? Text(
                    (comment.author?.name?.substring(0, 1) ?? '?').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF000000),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.author?.name?.toUpperCase() ?? 'ANONYMOUS',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Premium badge for comments
                    if (comment.author?.winterArcTier == 'premium') ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(comment.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: GritColors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFE0E0E0),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _CommentInput({
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C34),
        border: Border(
          top: BorderSide(
            color: Color(0xFF4A4A52),
            width: 2,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(
                  color: GritColors.grey,
                ),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: const Color(0xFF4A4A52),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: const Color(0xFF4A4A52),
                    width: 1,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF4A90E2),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onSubmit,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: GritColors.black,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:alphagrit/app/theme/theme.dart';
import 'package:alphagrit/features/community/community_controller.dart';
import 'package:alphagrit/domain/models/community.dart';

class CommunityFeedScreen extends ConsumerStatefulWidget {
  final int programId;
  final String programTitle;

  const CommunityFeedScreen({
    super.key,
    required this.programId,
    required this.programTitle,
  });

  @override
  ConsumerState<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends ConsumerState<CommunityFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(communityPostsProvider(widget.programId));

    return Scaffold(
      backgroundColor: GritColors.black,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.programTitle.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const Text(
              'COMMUNITY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: Color(0xFF4A90E2),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showCommunityGuidelines(context);
            },
          ),
        ],
      ),
      body: postsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4A90E2),
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: GritColors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load community feed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: GritColors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: GritColors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (posts) {
          if (posts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(communityPostsProvider(widget.programId));
            },
            color: const Color(0xFF4A90E2),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _PostCard(
                  post: posts[index],
                  onTap: () {
                    // Navigate to post detail screen
                    context.push('/community/post/${posts[index].id}');
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/community/create-post?programId=${widget.programId}');
        },
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: GritColors.black,
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          'NEW POST',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4A90E2),
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.groups,
                size: 80,
                color: Color(0xFF4A90E2),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'BE THE FIRST',
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Color(0xFFFFFFFF),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'No posts yet. Share your journey and inspire others.',
              style: TextStyle(
                fontSize: 16,
                color: GritColors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: GritColors.black,
                  shape: const BeveledRectangleBorder(),
                ),
                onPressed: () {
                  context.push('/community/create-post?programId=${widget.programId}');
                },
                child: const Text(
                  'CREATE POST',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommunityGuidelines(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C34),
        title: const Text(
          'COMMUNITY GUIDELINES',
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        content: const SingleChildScrollView(
          child: Text(
            '1. RESPECT OTHERS\nNo harassment, hate speech, or personal attacks.\n\n'
            '2. STAY ON TOPIC\nKeep posts relevant to the Winter Arc program.\n\n'
            '3. NO SPAM\nDon\'t post repetitive or promotional content.\n\n'
            '4. BE SUPPORTIVE\nEncourage others and celebrate victories.\n\n'
            '5. SHARE RESPONSIBLY\nRespect privacy and don\'t share sensitive info.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'GOT IT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4A90E2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final CommunityPost post;
  final VoidCallback onTap;

  const _PostCard({
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C34),
          border: Border.all(
            color: post.isPinned
                ? const Color(0xFFD97B3A)
                : const Color(0xFF4A4A52),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Author Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF4A90E2),
                    backgroundImage: post.author?.avatarUrl != null
                        ? NetworkImage(post.author!.avatarUrl!)
                        : null,
                    child: post.author?.avatarUrl == null
                        ? Text(
                            (post.author?.name?.substring(0, 1) ?? '?').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  color: Color(0xFFFFFFFF),
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
                            // Pinned badge
                            if (post.isPinned) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97B3A),
                                ),
                                child: const Text(
                                  'PINNED',
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

            // Post Content
            if (post.title != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  post.title!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            if (post.message != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  post.message!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFE0E0E0),
                    height: 1.5,
                  ),
                ),
              ),

            // Post Image
            if (post.photoUrl != null)
              Image.network(
                post.photoUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: const Color(0xFF1A1A1A),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Color(0xFF666666),
                      ),
                    ),
                  );
                },
              ),

            // Footer: Like & Comment Counts
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _IconWithCount(
                    icon: Icons.favorite,
                    count: post.likesCount,
                    color: const Color(0xFFFF1A1A),
                  ),
                  const SizedBox(width: 24),
                  _IconWithCount(
                    icon: Icons.comment,
                    count: post.commentsCount,
                    color: const Color(0xFF4A90E2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconWithCount extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _IconWithCount({
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 6),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ],
    );
  }
}

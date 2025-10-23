import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:alphagrit/app/providers.dart';
import 'package:alphagrit/features/winter_arc_guide/winter_arc_theme.dart';

/// Winter Arc Admin Screen - Manage premium posts and view stats
/// For Wagner to see and respond to premium tier posts
class WinterArcAdminScreen extends ConsumerStatefulWidget {
  final int programId;

  const WinterArcAdminScreen({
    super.key,
    this.programId = 1,
  });

  @override
  ConsumerState<WinterArcAdminScreen> createState() => _WinterArcAdminScreenState();
}

class _WinterArcAdminScreenState extends ConsumerState<WinterArcAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _allPosts = [];
  List<Map<String, dynamic>> _premiumPosts = [];
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => _loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(adminRepositoryProvider);
      if (repository == null) {
        setState(() {
          _error = 'Admin repository not available';
          _isLoading = false;
        });
        return;
      }

      final results = await Future.wait([
        repository.getPremiumPostsQueue(programId: widget.programId),
        repository.getPremiumStats(programId: widget.programId),
      ]);

      final posts = results[0] as List<Map<String, dynamic>>;
      final stats = results[1] as Map<String, dynamic>;

      // Separate premium posts (those needing response)
      final premiumPosts = posts.where((p) {
        final isPremium = p['user_tier'] == 'premium';
        final isResponded = p['responded_at'] != null;
        return isPremium && !isResponded;
      }).toList();

      if (mounted) {
        setState(() {
          _allPosts = posts;
          _premiumPosts = premiumPosts;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsResponded(int postId, String postTitle) async {
    try {
      final repository = ref.read(adminRepositoryProvider);
      if (repository == null) return;

      await repository.markPostResponded(postId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked "$postTitle" as responded'),
            backgroundColor: WinterArcTheme.iceBlue,
          ),
        );
        _loadData(); // Reload data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WinterArcTheme.black,
      appBar: AppBar(
        backgroundColor: WinterArcTheme.black,
        elevation: 0,
        title: Text(
          'WINTER ARC ADMIN',
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: WinterArcTheme.iceBlue,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            color: WinterArcTheme.iceBlue,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: WinterArcTheme.iceBlue,
          labelColor: WinterArcTheme.iceBlue,
          unselectedLabelColor: WinterArcTheme.lightGray,
          labelStyle: const TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('PREMIUM POSTS'),
                  if (_premiumPosts.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: WinterArcTheme.mutedOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_premiumPosts.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'ALL POSTS'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(WinterArcTheme.iceBlue),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading admin data...',
                    style: TextStyle(
                      fontSize: 14,
                      color: WinterArcTheme.lightGray,
                    ),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: WinterArcTheme.bloodRed,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: WinterArcTheme.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 14,
                            color: WinterArcTheme.lightGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WinterArcTheme.iceBlue,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('RETRY'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Stats bar
                    if (_stats != null) _buildStatsBar(),
                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPostsList(_premiumPosts, isPremiumTab: true),
                          _buildPostsList(_allPosts, isPremiumTab: false),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatsBar() {
    final stats = _stats!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WinterArcTheme.charcoal.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(color: WinterArcTheme.iceBlue.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Premium Users',
            '${stats['total_premium_users'] ?? 0}',
            WinterArcTheme.mutedOrange,
          ),
          _buildStatItem(
            'Premium Posts',
            '${stats['total_premium_posts'] ?? 0}',
            WinterArcTheme.iceBlue,
          ),
          _buildStatItem(
            'Need Response',
            '${stats['unresponded_posts'] ?? 0}',
            stats['unresponded_posts'] > 0 ? WinterArcTheme.bloodRed : WinterArcTheme.lightGray,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: WinterArcTheme.lightGray,
          ),
        ),
      ],
    );
  }

  Widget _buildPostsList(List<Map<String, dynamic>> posts, {required bool isPremiumTab}) {
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPremiumTab ? Icons.check_circle_outline : Icons.inbox_outlined,
                size: 64,
                color: WinterArcTheme.lightGray,
              ),
              const SizedBox(height: 16),
              Text(
                isPremiumTab ? 'All caught up!' : 'No posts yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: WinterArcTheme.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPremiumTab
                    ? 'No premium posts need your response right now.'
                    : 'Posts will appear here once users start posting.',
                style: TextStyle(
                  fontSize: 14,
                  color: WinterArcTheme.lightGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: WinterArcTheme.iceBlue,
      backgroundColor: WinterArcTheme.charcoal,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostCard(post, isPremiumTab: isPremiumTab);
        },
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, {required bool isPremiumTab}) {
    final postId = post['post_id'] as int;
    final title = post['title'] as String? ?? 'Untitled';
    final content = post['content'] as String? ?? '';
    final authorName = post['author_name'] as String? ?? 'Anonymous';
    final userTier = post['user_tier'] as String?;
    final isPremium = userTier == 'premium';
    final createdAt = post['created_at'] as String?;
    final respondedAt = post['responded_at'] as String?;
    final isResponded = respondedAt != null;

    DateTime? createdDate;
    if (createdAt != null) {
      try {
        createdDate = DateTime.parse(createdAt);
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: WinterArcTheme.charcoal,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPremium ? WinterArcTheme.mutedOrange : WinterArcTheme.iceBlue.withOpacity(0.2),
          width: isPremium ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with author and badges
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            authorName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: WinterArcTheme.white,
                            ),
                          ),
                          if (isPremium) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: WinterArcTheme.mutedOrange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PREMIUM',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (createdDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          timeago.format(createdDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: WinterArcTheme.lightGray,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isResponded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'RESPONDED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: WinterArcTheme.white,
                  ),
                ),
                if (content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: WinterArcTheme.lightGray,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Action buttons
          if (isPremiumTab && !isResponded) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _markAsResponded(postId, title),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('MARK AS RESPONDED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WinterArcTheme.iceBlue,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ] else
            const SizedBox(height: 16),
        ],
      ),
    );
  }
}

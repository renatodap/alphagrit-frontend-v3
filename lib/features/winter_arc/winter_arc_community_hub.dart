import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alphagrit/data/repositories/winter_arc_repository.dart';
import 'package:alphagrit/app/providers.dart';
import 'package:alphagrit/features/community/community_feed_screen.dart';
import 'package:alphagrit/features/winter_arc_guide/winter_arc_leaderboard_screen.dart';
import 'package:alphagrit/features/winter_arc_guide/winter_arc_progress_screen.dart';
import 'package:alphagrit/features/winter_arc_guide/widgets/paywall_overlay.dart';
import 'package:alphagrit/features/winter_arc_guide/winter_arc_theme.dart';

/// Winter Arc Community Hub - Main hub with tabs for Feed, Challenge, and Profile
/// Shows paywall if user doesn't have community access
class WinterArcCommunityHub extends ConsumerStatefulWidget {
  final int programId;

  const WinterArcCommunityHub({
    super.key,
    this.programId = 1, // Default to Winter Arc program
  });

  @override
  ConsumerState<WinterArcCommunityHub> createState() => _WinterArcCommunityHubState();
}

class _WinterArcCommunityHubState extends ConsumerState<WinterArcCommunityHub>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasAccess = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Delay to ensure provider is ready
    Future.microtask(() => _checkAccess());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAccess() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(winterArcRepositoryProvider);
      if (repository == null) {
        // Repository not ready yet, try again
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) _checkAccess();
        return;
      }

      // Check access
      final accessData = await repository.checkAccess(widget.programId);
      final hasCommunityAccess = accessData['has_community_access'] as bool? ?? false;

      if (mounted) {
        setState(() {
          _hasAccess = hasCommunityAccess;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If there's an error (like not authenticated), assume no access
      if (mounted) {
        setState(() {
          _hasAccess = false;
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: WinterArcTheme.black,
        body: Center(
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
                'Checking access...',
                style: TextStyle(
                  fontSize: 14,
                  color: WinterArcTheme.lightGray,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasAccess) {
      // User doesn't have community access - show paywall
      return Scaffold(
        backgroundColor: WinterArcTheme.black,
        body: PaywallOverlay(contentType: 'community'),
      );
    }

    // User has access - show the community hub
    final repository = ref.read(winterArcRepositoryProvider);
    if (repository == null) {
      return Scaffold(
        backgroundColor: WinterArcTheme.black,
        body: Center(
          child: Text(
            'Error: Repository not available',
            style: TextStyle(color: WinterArcTheme.lightGray),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: WinterArcTheme.black,
      appBar: AppBar(
        backgroundColor: WinterArcTheme.black,
        elevation: 0,
        title: Text(
          'WINTER ARC COMMUNITY',
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: WinterArcTheme.iceBlue,
          ),
        ),
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
          tabs: const [
            Tab(text: 'FEED'),
            Tab(text: 'CHALLENGE'),
            Tab(text: 'PROFILE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Feed - Community posts (bilingual: English + Portuguese together)
          // Note: CommunityFeedScreen has its own Scaffold, which is okay here
          // because we want its FAB and we're hiding the redundant AppBar below
          CommunityFeedScreen(
            programId: widget.programId,
            programTitle: 'Winter Arc',
          ),

          // Tab 2: Challenge - Leaderboard and competition
          // Extract just the body without the Scaffold/AppBar
          _LeaderboardTabContent(
            programId: widget.programId,
            repository: repository,
          ),

          // Tab 3: Profile - Personal metrics and progress
          // Extract just the body without the Scaffold/AppBar
          _ProgressTabContent(
            programId: widget.programId,
            repository: repository,
          ),
        ],
      ),
    );
  }
}

/// Wrapper for Leaderboard tab content (without Scaffold/AppBar to avoid nesting)
class _LeaderboardTabContent extends StatelessWidget {
  final int programId;
  final WinterArcRepository repository;

  const _LeaderboardTabContent({
    required this.programId,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap the leaderboard screen without its AppBar since the parent hub has one
    return WinterArcLeaderboardScreen(
      programId: programId,
      repository: repository,
      showAppBar: false, // Hide AppBar to avoid nesting
    );
  }
}

/// Wrapper for Progress tab content (without AppBar to avoid nesting)
class _ProgressTabContent extends StatelessWidget {
  final int programId;
  final WinterArcRepository repository;

  const _ProgressTabContent({
    required this.programId,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap the progress screen without its AppBar since the parent hub has one
    return WinterArcProgressScreen(
      programId: programId,
      repository: repository,
      showAppBar: false, // Hide AppBar to avoid nesting
    );
  }
}

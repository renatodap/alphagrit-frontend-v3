import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:alphagrit/data/repositories/winter_arc_repository.dart';
import 'winter_arc_theme.dart';

/// Winter Arc Leaderboard - Compete with other warriors
class WinterArcLeaderboardScreen extends StatefulWidget {
  final int programId;
  final WinterArcRepository repository;
  final bool showAppBar;

  const WinterArcLeaderboardScreen({
    super.key,
    required this.programId,
    required this.repository,
    this.showAppBar = true,
  });

  @override
  State<WinterArcLeaderboardScreen> createState() => _WinterArcLeaderboardScreenState();
}

class _WinterArcLeaderboardScreenState extends State<WinterArcLeaderboardScreen> {
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _topPlayers = [];
  Map<String, dynamic>? _myPosition;
  Map<String, dynamic>? _leaderboardContext;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        widget.repository.getLeaderboard(widget.programId, limit: 100),
        widget.repository.getMyLeaderboardPosition(widget.programId),
        widget.repository.getLeaderboardContext(widget.programId, contextSize: 3),
      ]);

      setState(() {
        _topPlayers = results[0] as List<Map<String, dynamic>>;
        _myPosition = results[1] as Map<String, dynamic>?;
        _leaderboardContext = results[2] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load leaderboard';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = WinterArcTheme.isMobile(context);

    return Scaffold(
      backgroundColor: WinterArcTheme.black,
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(
                'WINTER ARC LEADERBOARD',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              backgroundColor: WinterArcTheme.charcoal,
              actions: [
                IconButton(
                  onPressed: _loadLeaderboard,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            )
          : null,
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : _buildContent(isMobile),
    );
  }

  Widget _buildLoadingState() {
    return Center(
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
          const SizedBox(height: WinterArcTheme.spacingL),
          Text(
            'Loading leaderboard...',
            style: WinterArcTheme.bodyMedium.copyWith(
              color: WinterArcTheme.lightGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(WinterArcTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: WinterArcTheme.spacingL),
            Text(
              _error!,
              style: WinterArcTheme.subsectionTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: WinterArcTheme.spacingL),
            ElevatedButton(
              onPressed: _loadLeaderboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: WinterArcTheme.iceBlue,
              ),
              child: Text('RETRY', style: WinterArcTheme.buttonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      color: WinterArcTheme.iceBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My position card
            if (_myPosition != null) ...[
              _buildMyPositionCard(isMobile),
              const SizedBox(height: WinterArcTheme.spacingXL),
            ],

            // Top 3 podium
            if (_topPlayers.length >= 3) ...[
              Text(
                'TOP WARRIORS',
                style: isMobile
                    ? WinterArcTheme.sectionTitleMobile
                    : WinterArcTheme.sectionTitle,
              ),
              const SizedBox(height: WinterArcTheme.spacingM),
              _buildPodium(isMobile),
              const SizedBox(height: WinterArcTheme.spacingXL),
            ],

            // Full leaderboard
            Text(
              'ALL RANKINGS',
              style: isMobile
                  ? WinterArcTheme.sectionTitleMobile
                  : WinterArcTheme.sectionTitle,
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildFullLeaderboard(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPositionCard(bool isMobile) {
    final rank = _myPosition!['leaderboard_rank'] as int?;
    final score = (_myPosition!['leaderboard_score'] as num?)?.toDouble() ?? 0.0;
    final dailyStreak = _myPosition!['current_daily_streak'] as int? ?? 0;
    final weeklyStreak = _myPosition!['current_weekly_streak'] as int? ?? 0;

    return Container(
      padding: EdgeInsets.all(isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL),
      decoration: BoxDecoration(
        gradient: WinterArcTheme.accentGradient,
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        boxShadow: WinterArcTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: WinterArcTheme.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: WinterArcTheme.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR POSITION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WinterArcTheme.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rank != null ? 'Rank #$rank' : 'Not Ranked',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: WinterArcTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${score.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: WinterArcTheme.white,
                    ),
                  ),
                  Text(
                    'POINTS',
                    style: TextStyle(
                      fontSize: 11,
                      color: WinterArcTheme.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: WinterArcTheme.white.withOpacity(0.3)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatPill('$dailyStreak days', Icons.local_fire_department),
              _buildStatPill('$weeklyStreak weeks', Icons.calendar_month),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: WinterArcTheme.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: WinterArcTheme.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: WinterArcTheme.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(bool isMobile) {
    final first = _topPlayers[0];
    final second = _topPlayers.length > 1 ? _topPlayers[1] : null;
    final third = _topPlayers.length > 2 ? _topPlayers[2] : null;

    return isMobile
        ? Column(
            children: [
              if (first != null) _buildPodiumCard(first, 1, Colors.amber),
              const SizedBox(height: 12),
              if (second != null) _buildPodiumCard(second, 2, Colors.grey[400]!),
              const SizedBox(height: 12),
              if (third != null) _buildPodiumCard(third, 3, Colors.brown[300]!),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (second != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: _buildPodiumCard(second, 2, Colors.grey[400]!),
                  ),
                ),
              const SizedBox(width: 8),
              if (first != null) Expanded(child: _buildPodiumCard(first, 1, Colors.amber)),
              const SizedBox(width: 8),
              if (third != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: _buildPodiumCard(third, 3, Colors.brown[300]!),
                  ),
                ),
            ],
          );
  }

  Widget _buildPodiumCard(Map<String, dynamic> player, int rank, Color medalColor) {
    final score = (player['leaderboard_score'] as num?)?.toDouble() ?? 0.0;
    final dailyStreak = player['current_daily_streak'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WinterArcTheme.darkGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: medalColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events, color: medalColor, size: 40),
          const SizedBox(height: 8),
          Text(
            '#$rank',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: medalColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${score.toStringAsFixed(0)} pts',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: WinterArcTheme.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$dailyStreak day streak',
            style: TextStyle(
              fontSize: 12,
              color: WinterArcTheme.lightGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullLeaderboard(bool isMobile) {
    if (_topPlayers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(WinterArcTheme.spacingL),
        decoration: BoxDecoration(
          color: WinterArcTheme.darkGray,
          borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        ),
        child: Center(
          child: Text(
            'No one on the leaderboard yet. Be the first!',
            style: WinterArcTheme.bodyMedium.copyWith(color: WinterArcTheme.lightGray),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: WinterArcTheme.darkGray,
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        border: Border.all(color: WinterArcTheme.gray.withOpacity(0.3)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _topPlayers.length,
        separatorBuilder: (context, index) => Divider(
          color: WinterArcTheme.gray.withOpacity(0.2),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final player = _topPlayers[index];
          final isMe = _myPosition != null &&
              player['user_id'] == _myPosition!['user_id'];

          return _buildLeaderboardRow(player, index + 1, isMe, isMobile);
        },
      ),
    );
  }

  Widget _buildLeaderboardRow(
    Map<String, dynamic> player,
    int rank,
    bool isMe,
    bool isMobile,
  ) {
    final score = (player['leaderboard_score'] as num?)?.toDouble() ?? 0.0;
    final dailyStreak = player['current_daily_streak'] as int? ?? 0;
    final weeklyStreak = player['current_weekly_streak'] as int? ?? 0;

    Color rankColor;
    if (rank == 1) {
      rankColor = Colors.amber;
    } else if (rank == 2) {
      rankColor = Colors.grey[400]!;
    } else if (rank == 3) {
      rankColor = Colors.brown[300]!;
    } else {
      rankColor = WinterArcTheme.lightGray;
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      color: isMe ? WinterArcTheme.iceBlue.withOpacity(0.05) : null,
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: rankColor, width: 2),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: rankColor,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${score.toStringAsFixed(0)} points',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: isMe ? WinterArcTheme.iceBlue : WinterArcTheme.white,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: WinterArcTheme.iceBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'YOU',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: WinterArcTheme.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '$dailyStreak',
                      style: TextStyle(
                        fontSize: 12,
                        color: WinterArcTheme.lightGray,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.calendar_month,
                        size: 14, color: WinterArcTheme.iceBlue),
                    const SizedBox(width: 4),
                    Text(
                      '$weeklyStreak',
                      style: TextStyle(
                        fontSize: 12,
                        color: WinterArcTheme.lightGray,
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

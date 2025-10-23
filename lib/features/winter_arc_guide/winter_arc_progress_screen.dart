import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:alphagrit/data/repositories/winter_arc_repository.dart';
import 'winter_arc_theme.dart';

/// Winter Arc Progress Dashboard - Shows user's journey, stats, and achievements
class WinterArcProgressScreen extends StatefulWidget {
  final int programId;
  final WinterArcRepository repository;
  final bool showAppBar;

  const WinterArcProgressScreen({
    super.key,
    required this.programId,
    required this.repository,
    this.showAppBar = true,
  });

  @override
  State<WinterArcProgressScreen> createState() => _WinterArcProgressScreenState();
}

class _WinterArcProgressScreenState extends State<WinterArcProgressScreen> {
  bool _isLoading = true;
  String? _error;

  // Progress data
  Map<String, dynamic> _progress = {};
  List<Map<String, dynamic>> _achievements = [];
  List<Map<String, dynamic>> _dailyChecklists = [];
  List<Map<String, dynamic>> _snapshots = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all data in parallel
      final results = await Future.wait([
        widget.repository.getProgress(widget.programId),
        widget.repository.getAchievementProgress(widget.programId),
        widget.repository.getDailyChecklistRange(
          widget.programId,
          DateTime.now().subtract(const Duration(days: 90)),
          DateTime.now(),
        ),
        widget.repository.getSnapshots(widget.programId, limit: 20),
      ]);

      setState(() {
        _progress = results[0] as Map<String, dynamic>;
        _achievements = results[1] as List<Map<String, dynamic>>;
        _dailyChecklists = results[2] as List<Map<String, dynamic>>;
        _snapshots = results[3] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load progress data';
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
                'MY WINTER ARC PROGRESS',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              backgroundColor: WinterArcTheme.charcoal,
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
            'Loading your journey...',
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: WinterArcTheme.spacingL),
            Text(
              _error!,
              style: WinterArcTheme.subsectionTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: WinterArcTheme.spacingL),
            ElevatedButton(
              onPressed: _loadAllData,
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero stats cards
          _buildHeroStats(isMobile),

          const SizedBox(height: WinterArcTheme.spacingXL),

          // Streaks section
          Text(
            'STREAKS',
            style: isMobile
                ? WinterArcTheme.sectionTitleMobile
                : WinterArcTheme.sectionTitle,
          ),
          const SizedBox(height: WinterArcTheme.spacingM),
          _buildStreaksSection(isMobile),

          const SizedBox(height: WinterArcTheme.spacingXL),

          // Weight progress
          if (_snapshots.isNotEmpty) ...[
            Text(
              'WEIGHT PROGRESS',
              style: isMobile
                  ? WinterArcTheme.sectionTitleMobile
                  : WinterArcTheme.sectionTitle,
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildWeightProgress(isMobile),
            const SizedBox(height: WinterArcTheme.spacingXL),
          ],

          // Activity heatmap
          Text(
            'ACTIVITY HEATMAP',
            style: isMobile
                ? WinterArcTheme.sectionTitleMobile
                : WinterArcTheme.sectionTitle,
          ),
          const SizedBox(height: WinterArcTheme.spacingM),
          _buildActivityHeatmap(isMobile),

          const SizedBox(height: WinterArcTheme.spacingXL),

          // Achievements
          Text(
            'ACHIEVEMENTS',
            style: isMobile
                ? WinterArcTheme.sectionTitleMobile
                : WinterArcTheme.sectionTitle,
          ),
          const SizedBox(height: WinterArcTheme.spacingM),
          _buildAchievements(isMobile),
        ],
      ),
    );
  }

  Widget _buildHeroStats(bool isMobile) {
    final dailyStreak = _progress['current_daily_streak'] ?? 0;
    final weeklyStreak = _progress['current_weekly_streak'] ?? 0;
    final totalDays = _progress['total_days_completed'] ?? 0;
    final timerSessions = _progress['three_min_timer_completions'] ?? 0;

    return isMobile
        ? Column(
            children: [
              _buildStatCard('Daily Streak', '$dailyStreak days', Icons.local_fire_department),
              const SizedBox(height: WinterArcTheme.spacingM),
              _buildStatCard('Weekly Streak', '$weeklyStreak weeks', Icons.calendar_month),
              const SizedBox(height: WinterArcTheme.spacingM),
              _buildStatCard('Total Days', '$totalDays completed', Icons.check_circle),
              const SizedBox(height: WinterArcTheme.spacingM),
              _buildStatCard('Timer Sessions', '$timerSessions completed', Icons.timer),
            ],
          )
        : Wrap(
            spacing: WinterArcTheme.spacingM,
            runSpacing: WinterArcTheme.spacingM,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - WinterArcTheme.spacingL * 3) / 2,
                child: _buildStatCard('Daily Streak', '$dailyStreak days', Icons.local_fire_department),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - WinterArcTheme.spacingL * 3) / 2,
                child: _buildStatCard('Weekly Streak', '$weeklyStreak weeks', Icons.calendar_month),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - WinterArcTheme.spacingL * 3) / 2,
                child: _buildStatCard('Total Days', '$totalDays completed', Icons.check_circle),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - WinterArcTheme.spacingL * 3) / 2,
                child: _buildStatCard('Timer Sessions', '$timerSessions completed', Icons.timer),
              ),
            ],
          );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(WinterArcTheme.spacingM),
      decoration: BoxDecoration(
        gradient: WinterArcTheme.accentGradient,
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        boxShadow: WinterArcTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(WinterArcTheme.spacingS),
            decoration: BoxDecoration(
              color: WinterArcTheme.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
            ),
            child: Icon(icon, color: WinterArcTheme.white, size: 28),
          ),
          const SizedBox(width: WinterArcTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: WinterArcTheme.white.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: WinterArcTheme.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreaksSection(bool isMobile) {
    final currentDaily = _progress['current_daily_streak'] ?? 0;
    final longestDaily = _progress['longest_daily_streak'] ?? 0;
    final currentWeekly = _progress['current_weekly_streak'] ?? 0;
    final longestWeekly = _progress['longest_weekly_streak'] ?? 0;

    return Container(
      padding: EdgeInsets.all(isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL),
      decoration: BoxDecoration(
        color: WinterArcTheme.darkGray,
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        border: Border.all(color: WinterArcTheme.iceBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildStreakRow('Daily Streak', currentDaily, longestDaily, Icons.wb_sunny),
          const Divider(color: WinterArcTheme.gray, height: WinterArcTheme.spacingL),
          _buildStreakRow('Weekly Streak', currentWeekly, longestWeekly, Icons.calendar_view_week),
        ],
      ),
    );
  }

  Widget _buildStreakRow(String label, int current, int longest, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: WinterArcTheme.iceBlue, size: 32),
        const SizedBox(width: WinterArcTheme.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: WinterArcTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Current: ',
                    style: TextStyle(fontSize: 14, color: WinterArcTheme.lightGray),
                  ),
                  Text(
                    '$current',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: WinterArcTheme.iceBlue,
                    ),
                  ),
                  const SizedBox(width: WinterArcTheme.spacingM),
                  Text(
                    'Best: ',
                    style: TextStyle(fontSize: 14, color: WinterArcTheme.lightGray),
                  ),
                  Text(
                    '$longest',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightProgress(bool isMobile) {
    if (_snapshots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(WinterArcTheme.spacingL),
        decoration: BoxDecoration(
          color: WinterArcTheme.darkGray,
          borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        ),
        child: Text(
          'No weight data yet. Start tracking!',
          style: WinterArcTheme.bodyMedium.copyWith(color: WinterArcTheme.lightGray),
        ),
      );
    }

    final first = _snapshots.last;
    final latest = _snapshots.first;
    final firstWeight = first['weight_kg'] as num;
    final latestWeight = latest['weight_kg'] as num;
    final change = latestWeight - firstWeight;
    final changePercent = ((change / firstWeight) * 100).abs();

    return Container(
      padding: EdgeInsets.all(isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL),
      decoration: BoxDecoration(
        color: WinterArcTheme.darkGray,
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        border: Border.all(color: WinterArcTheme.iceBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeightStat('Start', '${firstWeight.toStringAsFixed(1)} kg'),
              Icon(Icons.arrow_forward, color: WinterArcTheme.iceBlue),
              _buildWeightStat('Current', '${latestWeight.toStringAsFixed(1)} kg'),
            ],
          ),
          const SizedBox(height: WinterArcTheme.spacingM),
          Container(
            padding: const EdgeInsets.all(WinterArcTheme.spacingS),
            decoration: BoxDecoration(
              color: change < 0 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
            ),
            child: Text(
              '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)} kg (${changePercent.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: change < 0 ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: WinterArcTheme.white,
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

  Widget _buildActivityHeatmap(bool isMobile) {
    // Get last 90 days
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 89));

    // Create a map of dates to completion percentages
    final Map<String, double> completionMap = {};
    for (var checklist in _dailyChecklists) {
      final dateStr = checklist['checklist_date'] as String;
      final completion = (checklist['completion_percentage'] as num?)?.toDouble() ?? 0.0;
      completionMap[dateStr] = completion;
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL),
      decoration: BoxDecoration(
        color: WinterArcTheme.darkGray,
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        border: Border.all(color: WinterArcTheme.iceBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 90 Days',
            style: WinterArcTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: WinterArcTheme.spacingM),
          _buildHeatmapGrid(startDate, completionMap, isMobile),
          const SizedBox(height: WinterArcTheme.spacingM),
          _buildHeatmapLegend(),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid(DateTime startDate, Map<String, double> completionMap, bool isMobile) {
    final cellSize = isMobile ? 10.0 : 12.0;
    final spacing = isMobile ? 2.0 : 3.0;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: List.generate(90, (index) {
        final date = startDate.add(Duration(days: index));
        final dateStr = date.toIso8601String().split('T')[0];
        final completion = completionMap[dateStr] ?? 0.0;

        return Container(
          width: cellSize,
          height: cellSize,
          decoration: BoxDecoration(
            color: _getHeatmapColor(completion),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Color _getHeatmapColor(double completion) {
    if (completion == 0) return WinterArcTheme.charcoal;
    if (completion < 25) return WinterArcTheme.iceBlue.withOpacity(0.2);
    if (completion < 50) return WinterArcTheme.iceBlue.withOpacity(0.4);
    if (completion < 75) return WinterArcTheme.iceBlue.withOpacity(0.7);
    return WinterArcTheme.iceBlue;
  }

  Widget _buildHeatmapLegend() {
    return Row(
      children: [
        Text('Less', style: TextStyle(fontSize: 11, color: WinterArcTheme.lightGray)),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(left: 3),
            decoration: BoxDecoration(
              color: _getHeatmapColor(index * 25.0),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text('More', style: TextStyle(fontSize: 11, color: WinterArcTheme.lightGray)),
      ],
    );
  }

  Widget _buildAchievements(bool isMobile) {
    final unlocked = _achievements.where((a) => a['unlocked'] == true).toList();
    final locked = _achievements.where((a) => a['unlocked'] != true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (unlocked.isNotEmpty) ...[
          Text(
            'Unlocked (${unlocked.length})',
            style: WinterArcTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: WinterArcTheme.iceBlue,
            ),
          ),
          const SizedBox(height: WinterArcTheme.spacingM),
          Wrap(
            spacing: WinterArcTheme.spacingM,
            runSpacing: WinterArcTheme.spacingM,
            children: unlocked.map((a) => _buildAchievementBadge(a, true, isMobile)).toList(),
          ),
          const SizedBox(height: WinterArcTheme.spacingL),
        ],
        if (locked.isNotEmpty) ...[
          Text(
            'In Progress (${locked.length})',
            style: WinterArcTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: WinterArcTheme.lightGray,
            ),
          ),
          const SizedBox(height: WinterArcTheme.spacingM),
          Wrap(
            spacing: WinterArcTheme.spacingM,
            runSpacing: WinterArcTheme.spacingM,
            children: locked.map((a) => _buildAchievementBadge(a, false, isMobile)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildAchievementBadge(Map<String, dynamic> achievement, bool unlocked, bool isMobile) {
    final ach = achievement['achievement'] as Map<String, dynamic>;
    final name = ach['name'] as String;
    final description = ach['description'] as String;
    final percentage = achievement['percentage'] as int? ?? 0;

    return Container(
      width: isMobile ? double.infinity : 280,
      padding: const EdgeInsets.all(WinterArcTheme.spacingM),
      decoration: BoxDecoration(
        color: unlocked
            ? WinterArcTheme.iceBlue.withOpacity(0.1)
            : WinterArcTheme.charcoal,
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        border: Border.all(
          color: unlocked ? WinterArcTheme.iceBlue : WinterArcTheme.gray,
          width: unlocked ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                unlocked ? Icons.emoji_events : Icons.lock_outline,
                color: unlocked ? Colors.amber : WinterArcTheme.gray,
                size: 28,
              ),
              const SizedBox(width: WinterArcTheme.spacingS),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: unlocked ? WinterArcTheme.white : WinterArcTheme.lightGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: WinterArcTheme.spacingS),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: WinterArcTheme.lightGray,
            ),
          ),
          if (!unlocked) ...[
            const SizedBox(height: WinterArcTheme.spacingS),
            LinearProgressIndicator(
              value: percentage / 100.0,
              backgroundColor: WinterArcTheme.gray,
              valueColor: AlwaysStoppedAnimation(WinterArcTheme.iceBlue),
            ),
            const SizedBox(height: 4),
            Text(
              '$percentage% complete',
              style: TextStyle(
                fontSize: 11,
                color: WinterArcTheme.lightGray,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

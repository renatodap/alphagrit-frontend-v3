import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:alphagrit/data/repositories/winter_arc_repository.dart';
import '../winter_arc_theme.dart';

/// Persistent timer widget that tracks completions to backend
class PersistentTimerWidget extends StatefulWidget {
  final int durationMinutes;
  final String title;
  final String description;
  final int programId;
  final WinterArcRepository repository;

  const PersistentTimerWidget({
    super.key,
    this.durationMinutes = 3,
    this.title = '3-Minute Rule Timer',
    this.description = 'Start any task for just 3 minutes to break the cycle of inertia',
    required this.programId,
    required this.repository,
  });

  @override
  State<PersistentTimerWidget> createState() => _PersistentTimerWidgetState();
}

class _PersistentTimerWidgetState extends State<PersistentTimerWidget> {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  int _totalCompletions = 0;
  int _totalMinutes = 0;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationMinutes * 60;
    _loadStats();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await widget.repository.getProgress(widget.programId);
      setState(() {
        _totalCompletions = data['three_min_timer_completions'] ?? 0;
        _totalMinutes = data['total_timer_minutes'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (e is DioException && e.response?.statusCode != 404) {
          // Ignore 404, just means no data yet
        }
      });
    }
  }

  Future<void> _trackCompletion() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await widget.repository.incrementTimer(
        widget.programId,
        minutes: widget.durationMinutes,
      );

      // Update local stats
      setState(() {
        _totalCompletions++;
        _totalMinutes += widget.durationMinutes;
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      // Still count locally even if save fails
      setState(() {
        _totalCompletions++;
        _totalMinutes += widget.durationMinutes;
      });
    }
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      if (_secondsRemaining == 0) {
        _secondsRemaining = widget.durationMinutes * 60;
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _onTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
    });
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
      _secondsRemaining = widget.durationMinutes * 60;
    });
  }

  void _onTimerComplete() {
    // Track completion
    _trackCompletion();

    // Show completion dialog
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WinterArcTheme.darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: WinterArcTheme.iceBlue, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Time\'s Up!',
                style: WinterArcTheme.subsectionTitle,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You\'ve completed ${widget.durationMinutes} minutes. Keep going or take a break - you\'ve broken the inertia!',
              style: WinterArcTheme.bodyMedium,
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            Container(
              padding: const EdgeInsets.all(WinterArcTheme.spacingS),
              decoration: BoxDecoration(
                color: WinterArcTheme.iceBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
                border: Border.all(color: WinterArcTheme.iceBlue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$_totalCompletions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: WinterArcTheme.iceBlue,
                        ),
                      ),
                      Text(
                        'Total Sessions',
                        style: TextStyle(
                          fontSize: 11,
                          color: WinterArcTheme.lightGray,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$_totalMinutes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: WinterArcTheme.iceBlue,
                        ),
                      ),
                      Text(
                        'Total Minutes',
                        style: TextStyle(
                          fontSize: 11,
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetTimer();
            },
            child: Text(
              'DONE',
              style: TextStyle(color: WinterArcTheme.iceBlue),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime() {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double _getProgress() {
    final totalSeconds = widget.durationMinutes * 60;
    return (_secondsRemaining / totalSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = WinterArcTheme.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL),
      decoration: BoxDecoration(
        color: WinterArcTheme.darkGray,
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        border: Border.all(
          color: WinterArcTheme.iceBlue.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: WinterArcTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Title
          Text(
            widget.title,
            style: isMobile
                ? WinterArcTheme.subsectionTitleMobile
                : WinterArcTheme.subsectionTitle,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: WinterArcTheme.spacingS),

          Text(
            widget.description,
            style: isMobile
                ? WinterArcTheme.bodyMediumMobile
                : WinterArcTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          // Stats row
          if (!_isLoading) ...[
            const SizedBox(height: WinterArcTheme.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatBadge('$_totalCompletions', 'Sessions'),
                const SizedBox(width: WinterArcTheme.spacingM),
                _buildStatBadge('$_totalMinutes', 'Minutes'),
              ],
            ),
          ],

          SizedBox(height: isMobile ? WinterArcTheme.spacingL : WinterArcTheme.spacingXL),

          // Circular timer display
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: isMobile ? 180 : 220,
                height: isMobile ? 180 : 220,
                child: CircularProgressIndicator(
                  value: _getProgress(),
                  strokeWidth: 12,
                  backgroundColor: WinterArcTheme.charcoal,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isRunning ? WinterArcTheme.iceBlue : WinterArcTheme.gray,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(),
                    style: TextStyle(
                      fontSize: isMobile ? 48 : 64,
                      fontWeight: FontWeight.w900,
                      color: WinterArcTheme.white,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    _isRunning ? 'Running...' : 'Ready',
                    style: WinterArcTheme.bodyMedium.copyWith(
                      color: _isRunning ? WinterArcTheme.iceBlue : WinterArcTheme.lightGray,
                    ),
                  ),
                  if (_isSaving) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Saving...',
                      style: TextStyle(
                        fontSize: 11,
                        color: WinterArcTheme.iceBlue,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          SizedBox(height: isMobile ? WinterArcTheme.spacingL : WinterArcTheme.spacingXL),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Start/Pause button
              ElevatedButton.icon(
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                label: Text(_isRunning ? 'PAUSE' : 'START'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? WinterArcTheme.gray : WinterArcTheme.iceBlue,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL,
                    vertical: WinterArcTheme.spacingS,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
                  ),
                ),
              ),

              const SizedBox(width: WinterArcTheme.spacingM),

              // Reset button
              OutlinedButton.icon(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('RESET'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: WinterArcTheme.lightGray,
                  side: BorderSide(color: WinterArcTheme.gray),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL,
                    vertical: WinterArcTheme.spacingS,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: WinterArcTheme.spacingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: WinterArcTheme.charcoal,
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusS),
        border: Border.all(color: WinterArcTheme.iceBlue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: WinterArcTheme.iceBlue,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: WinterArcTheme.lightGray,
            ),
          ),
        ],
      ),
    );
  }
}

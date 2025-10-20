import 'dart:async';
import 'package:flutter/material.dart';
import '../winter_arc_theme.dart';

class TimerWidget extends StatefulWidget {
  final int durationMinutes;
  final String title;
  final String description;

  const TimerWidget({
    super.key,
    this.durationMinutes = 3,
    this.title = '3-Minute Rule Timer',
    this.description = 'Start any task for just 3 minutes to break the cycle of inertia',
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
          _showCompletionDialog();
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
        content: Text(
          'You\'ve completed ${widget.durationMinutes} minutes. Keep going or take a break - you\'ve broken the inertia!',
          style: WinterArcTheme.bodyMedium,
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
                  backgroundColor: _isRunning
                      ? WinterArcTheme.gray
                      : WinterArcTheme.iceBlue,
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
}

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:alphagrit/data/repositories/winter_arc_repository.dart';
import '../winter_arc_theme.dart';

/// Persistent checklist widget that saves progress to backend
///
/// Usage:
/// - For daily checklist: pass checklistType: 'daily'
/// - For weekly checklist: pass checklistType: 'weekly'
/// - Items map should match the backend field names (e.g., 'wake_up_early', 'workout')
class PersistentChecklistWidget extends StatefulWidget {
  final String title;
  final Map<String, String> items; // field_name -> display text
  final String checklistType; // 'daily' or 'weekly'
  final int programId;
  final WinterArcRepository repository;
  final bool showProgress;

  const PersistentChecklistWidget({
    super.key,
    required this.title,
    required this.items,
    required this.checklistType,
    required this.programId,
    required this.repository,
    this.showProgress = true,
  });

  @override
  State<PersistentChecklistWidget> createState() => _PersistentChecklistWidgetState();
}

class _PersistentChecklistWidgetState extends State<PersistentChecklistWidget> {
  Map<String, bool> _checkedItems = {};
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  DateTime? _lastSaved;

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Map<String, dynamic> data;

      if (widget.checklistType == 'daily') {
        data = await widget.repository.getTodayChecklist(widget.programId);
      } else {
        data = await widget.repository.getCurrentWeekChecklist(widget.programId);
      }

      // Initialize checked state from backend data
      final Map<String, bool> loadedState = {};
      for (final fieldName in widget.items.keys) {
        loadedState[fieldName] = data[fieldName] == true;
      }

      setState(() {
        _checkedItems = loadedState;
        _isLoading = false;
      });
    } catch (e) {
      // If checklist doesn't exist yet, initialize with all unchecked
      final Map<String, bool> initialState = {};
      for (final fieldName in widget.items.keys) {
        initialState[fieldName] = false;
      }

      setState(() {
        _checkedItems = initialState;
        _isLoading = false;
        if (e is DioException && e.response?.statusCode != 404) {
          _error = 'Failed to load checklist';
        }
      });
    }
  }

  Future<void> _saveChecklist() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      if (widget.checklistType == 'daily') {
        await widget.repository.updateDailyChecklist(
          widget.programId,
          DateTime.now(),
          _checkedItems,
        );
      } else {
        final now = DateTime.now();
        final weekday = now.weekday;
        final weekStart = now.subtract(Duration(days: weekday - 1));
        final year = weekStart.year;
        final week = _getIsoWeekNumber(weekStart);

        await widget.repository.updateWeeklyChecklist(
          widget.programId,
          year,
          week,
          _checkedItems,
        );
      }

      setState(() {
        _isSaving = false;
        _lastSaved = DateTime.now();
      });

      // Clear success indicator after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _lastSaved = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
        _error = 'Failed to save. Changes stored locally.';
      });
    }
  }

  int _getIsoWeekNumber(DateTime date) {
    final dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  void _toggleItem(String fieldName, bool newValue) {
    setState(() {
      _checkedItems[fieldName] = newValue;
    });

    // Auto-save after a short delay (debounce)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _saveChecklist();
      }
    });
  }

  int get _completedCount => _checkedItems.values.where((checked) => checked).length;

  double get _progress => _checkedItems.isEmpty ? 0.0 : _completedCount / _checkedItems.length;

  @override
  Widget build(BuildContext context) {
    final isMobile = WinterArcTheme.isMobile(context);

    if (_isLoading) {
      return _buildLoadingState(isMobile);
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: isMobile
                      ? WinterArcTheme.subsectionTitleMobile.copyWith(fontSize: 18)
                      : WinterArcTheme.subsectionTitle.copyWith(fontSize: 22),
                ),
              ),
              if (widget.showProgress) ...[
                const SizedBox(width: WinterArcTheme.spacingM),
                _buildProgressCircle(isMobile),
              ],
            ],
          ),

          // Saving indicator
          if (_isSaving || _lastSaved != null || _error != null) ...[
            const SizedBox(height: WinterArcTheme.spacingS),
            _buildStatusIndicator(isMobile),
          ],

          if (widget.showProgress) ...[
            const SizedBox(height: WinterArcTheme.spacingM),
            _buildProgressBar(),
          ],

          const SizedBox(height: WinterArcTheme.spacingM),

          // Checklist items
          ...widget.items.entries.map((entry) {
            final fieldName = entry.key;
            final displayText = entry.value;
            final isChecked = _checkedItems[fieldName] ?? false;

            return _buildChecklistItem(
              displayText,
              isChecked,
              (value) => _toggleItem(fieldName, value),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL),
      decoration: BoxDecoration(
        color: WinterArcTheme.darkGray,
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        border: Border.all(
          color: WinterArcTheme.iceBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(WinterArcTheme.iceBlue),
              ),
            ),
            const SizedBox(height: WinterArcTheme.spacingM),
            Text(
              'Loading checklist...',
              style: WinterArcTheme.bodyMedium.copyWith(
                color: WinterArcTheme.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isMobile) {
    IconData icon;
    String text;
    Color color;

    if (_isSaving) {
      icon = Icons.sync;
      text = 'Saving...';
      color = WinterArcTheme.iceBlue;
    } else if (_error != null) {
      icon = Icons.warning_amber_rounded;
      text = _error!;
      color = Colors.orange;
    } else {
      icon = Icons.check_circle;
      text = 'Saved';
      color = Colors.green;
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontStyle: _isSaving ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCircle(bool isMobile) {
    return Container(
      width: isMobile ? 50 : 60,
      height: isMobile ? 50 : 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: WinterArcTheme.iceBlue,
          width: 3,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_completedCount',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w800,
                color: WinterArcTheme.white,
              ),
            ),
            Text(
              '/${widget.items.length}',
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                color: WinterArcTheme.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: WinterArcTheme.charcoal,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: _progress,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: WinterArcTheme.accentGradient,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(_progress * 100).toStringAsFixed(0)}% Complete',
          style: const TextStyle(
            fontSize: 12,
            color: WinterArcTheme.lightGray,
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String text, bool isChecked, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Container(
        margin: const EdgeInsets.only(bottom: WinterArcTheme.spacingS),
        padding: const EdgeInsets.all(WinterArcTheme.spacingS),
        decoration: BoxDecoration(
          color: isChecked
              ? WinterArcTheme.iceBlue.withOpacity(0.1)
              : WinterArcTheme.charcoal,
          borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
          border: Border.all(
            color: isChecked
                ? WinterArcTheme.iceBlue.withOpacity(0.5)
                : WinterArcTheme.gray.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isChecked ? WinterArcTheme.iceBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked ? WinterArcTheme.iceBlue : WinterArcTheme.gray,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: WinterArcTheme.white,
                    )
                  : null,
            ),

            const SizedBox(width: WinterArcTheme.spacingS),

            // Text
            Expanded(
              child: Text(
                text,
                style: WinterArcTheme.bodyMedium.copyWith(
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  color: isChecked
                      ? WinterArcTheme.lightGray
                      : WinterArcTheme.offWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

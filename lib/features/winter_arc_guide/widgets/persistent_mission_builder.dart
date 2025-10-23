import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:alphagrit/data/repositories/winter_arc_repository.dart';
import '../winter_arc_theme.dart';

/// Persistent mission statement builder that saves to backend
class PersistentMissionStatementBuilder extends StatefulWidget {
  final int programId;
  final WinterArcRepository repository;

  const PersistentMissionStatementBuilder({
    super.key,
    required this.programId,
    required this.repository,
  });

  @override
  State<PersistentMissionStatementBuilder> createState() => _PersistentMissionStatementBuilderState();
}

class _PersistentMissionStatementBuilderState extends State<PersistentMissionStatementBuilder> {
  final _formKey = GlobalKey<FormState>();

  final _question1Controller = TextEditingController();
  final _question2Controller = TextEditingController();
  final _question3Controller = TextEditingController();

  String? _generatedStatement;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  DateTime? _lastSaved;

  @override
  void initState() {
    super.initState();
    _loadSavedMission();
  }

  @override
  void dispose() {
    _question1Controller.dispose();
    _question2Controller.dispose();
    _question3Controller.dispose();
    super.dispose();
  }

  Future<void> _loadSavedMission() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await widget.repository.getProgress(widget.programId);

      if (data['mission_statement'] != null) {
        setState(() {
          _generatedStatement = data['mission_statement'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (e is DioException && e.response?.statusCode != 404) {
          _error = 'Failed to load saved mission';
        }
      });
    }
  }

  Future<void> _saveMission(String mission) async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await widget.repository.updateProgress(
        widget.programId,
        {'mission_statement': mission},
      );

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
        _error = 'Failed to save mission';
      });
    }
  }

  void _generateStatement() {
    if (!_formKey.currentState!.validate()) return;

    final q1 = _question1Controller.text.trim();
    final q2 = _question2Controller.text.trim();
    final q3 = _question3Controller.text.trim();

    final statement = 'I use the rigor of winter to forge $q1, achieving $q2 and emerging as $q3.';

    setState(() {
      _generatedStatement = statement;
    });

    // Auto-save the generated statement
    _saveMission(statement);
  }

  void _copyToClipboard() {
    if (_generatedStatement != null) {
      Clipboard.setData(ClipboardData(text: _generatedStatement!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mission statement copied to clipboard!'),
          backgroundColor: WinterArcTheme.iceBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Create Your Winter Mission Statement',
              style: isMobile
                  ? WinterArcTheme.subsectionTitleMobile
                  : WinterArcTheme.subsectionTitle,
            ),

            const SizedBox(height: WinterArcTheme.spacingS),

            Text(
              'Answer these 3 questions to generate your personal mission statement',
              style: isMobile
                  ? WinterArcTheme.bodyMediumMobile
                  : WinterArcTheme.bodyMedium,
            ),

            // Status indicator
            if (_isSaving || _lastSaved != null || _error != null) ...[
              const SizedBox(height: WinterArcTheme.spacingS),
              _buildStatusIndicator(),
            ],

            const SizedBox(height: WinterArcTheme.spacingL),

            // Question 1
            _buildQuestion(
              '1. What do you want to build or strengthen in yourself this winter?',
              'Ex: discipline, physical strength, mental clarity',
              _question1Controller,
            ),

            const SizedBox(height: WinterArcTheme.spacingM),

            // Question 2
            _buildQuestion(
              '2. What tangible result do you want to achieve by the end of the season?',
              'Ex: lose 5kg of fat, read 4 books, complete a personal project',
              _question2Controller,
            ),

            const SizedBox(height: WinterArcTheme.spacingM),

            // Question 3
            _buildQuestion(
              '3. What kind of person will you be if you achieve this goal?',
              'Ex: more confident, more resilient, more focused',
              _question3Controller,
            ),

            const SizedBox(height: WinterArcTheme.spacingL),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generateStatement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WinterArcTheme.iceBlue,
                  padding: const EdgeInsets.symmetric(vertical: WinterArcTheme.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
                  ),
                ),
                child: Text(
                  'GENERATE & SAVE MY MISSION',
                  style: WinterArcTheme.buttonText.copyWith(
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ),
            ),

            // Generated statement
            if (_generatedStatement != null) ...[
              const SizedBox(height: WinterArcTheme.spacingXL),
              _buildGeneratedStatement(isMobile),
            ],
          ],
        ),
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
              'Loading mission builder...',
              style: WinterArcTheme.bodyMedium.copyWith(
                color: WinterArcTheme.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
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

  Widget _buildQuestion(String question, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: WinterArcTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: WinterArcTheme.iceBlue,
          ),
        ),
        const SizedBox(height: WinterArcTheme.spacingS),
        TextFormField(
          controller: controller,
          maxLines: 2,
          style: const TextStyle(color: WinterArcTheme.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: WinterArcTheme.lightGray.withOpacity(0.6),
              fontSize: 14,
            ),
            filled: true,
            fillColor: WinterArcTheme.charcoal,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
              borderSide: BorderSide(color: WinterArcTheme.gray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
              borderSide: BorderSide(color: WinterArcTheme.gray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
              borderSide: BorderSide(color: WinterArcTheme.iceBlue),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please answer this question';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGeneratedStatement(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            WinterArcTheme.iceBlue.withOpacity(0.2),
            WinterArcTheme.iceBlueLight.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(WinterArcTheme.radiusL),
        border: Border.all(
          color: WinterArcTheme.iceBlue,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: WinterArcTheme.iceBlue,
                size: isMobile ? 20 : 24,
              ),
              const SizedBox(width: WinterArcTheme.spacingS),
              Expanded(
                child: Text(
                  'Your Winter Mission Statement',
                  style: isMobile
                      ? WinterArcTheme.subsectionTitleMobile.copyWith(fontSize: 18)
                      : WinterArcTheme.subsectionTitle.copyWith(fontSize: 22),
                ),
              ),
            ],
          ),

          const SizedBox(height: WinterArcTheme.spacingM),

          // The statement
          Container(
            padding: const EdgeInsets.all(WinterArcTheme.spacingM),
            decoration: BoxDecoration(
              color: WinterArcTheme.charcoal.withOpacity(0.5),
              borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
            ),
            child: Text(
              '"$_generatedStatement"',
              style: isMobile
                  ? WinterArcTheme.pullQuoteMobile
                  : WinterArcTheme.pullQuote,
            ),
          ),

          const SizedBox(height: WinterArcTheme.spacingM),

          // Instructions
          Text(
            'Write this on your mirror, at your desk, or set it as your phone wallpaper. Read it every morning during your silence routine.',
            style: isMobile
                ? WinterArcTheme.bodyMediumMobile.copyWith(fontSize: 13)
                : WinterArcTheme.bodyMedium.copyWith(fontSize: 14),
          ),

          const SizedBox(height: WinterArcTheme.spacingM),

          // Copy button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy, size: 18),
              label: Text(
                'COPY TO CLIPBOARD',
                style: WinterArcTheme.buttonText.copyWith(fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: WinterArcTheme.iceBlue,
                side: BorderSide(color: WinterArcTheme.iceBlue),
                padding: const EdgeInsets.symmetric(vertical: WinterArcTheme.spacingS),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

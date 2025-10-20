import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../winter_arc_theme.dart';

class MissionStatementBuilder extends StatefulWidget {
  const MissionStatementBuilder({super.key});

  @override
  State<MissionStatementBuilder> createState() => _MissionStatementBuilderState();
}

class _MissionStatementBuilderState extends State<MissionStatementBuilder> {
  final _formKey = GlobalKey<FormState>();

  final _question1Controller = TextEditingController();
  final _question2Controller = TextEditingController();
  final _question3Controller = TextEditingController();

  String? _generatedStatement;

  @override
  void dispose() {
    _question1Controller.dispose();
    _question2Controller.dispose();
    _question3Controller.dispose();
    super.dispose();
  }

  void _generateStatement() {
    if (!_formKey.currentState!.validate()) return;

    final q1 = _question1Controller.text.trim();
    final q2 = _question2Controller.text.trim();
    final q3 = _question3Controller.text.trim();

    setState(() {
      _generatedStatement =
          'I use the rigor of winter to forge $q1, achieving $q2 and emerging as $q3.';
    });
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
                  'GENERATE MY MISSION STATEMENT',
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alphagrit/app/theme/theme.dart';

class PWAInstallPrompt extends StatefulWidget {
  const PWAInstallPrompt({super.key});

  @override
  State<PWAInstallPrompt> createState() => _PWAInstallPromptState();
}

class _PWAInstallPromptState extends State<PWAInstallPrompt> {
  bool _isVisible = false;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _checkShouldShow();
  }

  Future<void> _checkShouldShow() async {
    // Only show on web
    if (!kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    final dismissedDate = prefs.getString('pwa_install_dismissed_date');

    if (dismissedDate != null) {
      final dismissed = DateTime.parse(dismissedDate);
      final daysSinceDismissed = DateTime.now().difference(dismissed).inDays;

      // Show again after 7 days
      if (daysSinceDismissed < 7) {
        return;
      }
    }

    // Check if already installed (standalone mode)
    // This is a simple check - in production you might want to use a more robust method
    setState(() {
      _isVisible = true;
    });
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pwa_install_dismissed_date', DateTime.now().toIso8601String());

    setState(() {
      _isDismissed = true;
    });

    // Animate out
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || _isDismissed) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: _isDismissed ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A90E2), // frostBlue
              Color(0xFF1E3A5F), // steelBlue
            ],
          ),
          border: Border.all(
            color: const Color(0xFF4A90E2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A90E2).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GritColors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.install_mobile,
                    color: GritColors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'INSTALL ALPHAGRIT',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get the full app experience',
                        style: TextStyle(
                          fontSize: 14,
                          color: GritColors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _dismiss,
                  icon: const Icon(Icons.close, color: GritColors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Benefits
            _BenefitRow(
              icon: Icons.offline_bolt,
              text: 'Work offline',
            ),
            const SizedBox(height: 8),
            _BenefitRow(
              icon: Icons.speed,
              text: 'Faster loading',
            ),
            const SizedBox(height: 8),
            _BenefitRow(
              icon: Icons.notifications_active,
              text: 'Push notifications',
            ),
            const SizedBox(height: 20),

            // Install Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GritColors.black.withOpacity(0.3),
                border: Border.all(
                  color: GritColors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HOW TO INSTALL:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InstallStep(
                    platform: 'iOS/Safari',
                    steps: 'Tap Share → Add to Home Screen',
                  ),
                  const SizedBox(height: 8),
                  _InstallStep(
                    platform: 'Android/Chrome',
                    steps: 'Tap Menu (⋮) → Install App',
                  ),
                  const SizedBox(height: 8),
                  _InstallStep(
                    platform: 'Desktop',
                    steps: 'Click Install icon in address bar',
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

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: GritColors.white.withOpacity(0.9),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: GritColors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}

class _InstallStep extends StatelessWidget {
  final String platform;
  final String steps;

  const _InstallStep({
    required this.platform,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withOpacity(0.3),
            border: Border.all(
              color: const Color(0xFF4A90E2),
              width: 1,
            ),
          ),
          child: Text(
            platform,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            steps,
            style: TextStyle(
              fontSize: 12,
              color: GritColors.white.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}

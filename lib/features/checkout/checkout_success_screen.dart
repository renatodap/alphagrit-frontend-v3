import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:alphagrit/app/theme/theme.dart';
import 'dart:math' as math;

class CheckoutSuccessScreen extends StatefulWidget {
  const CheckoutSuccessScreen({super.key});

  @override
  State<CheckoutSuccessScreen> createState() => _CheckoutSuccessScreenState();
}

class _CheckoutSuccessScreenState extends State<CheckoutSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: GritColors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1E3A5F).withOpacity(0.3), // steelBlue
              GritColors.black,
              GritColors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Success Icon
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF4A90E2), width: 4), // frostBlue
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4A90E2).withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          size: 100,
                          color: Color(0xFF4A90E2), // frostBlue
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Success Message
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'WELCOME TO THE WINTER ARC',
                            style: TextStyle(
                              fontFamily: 'BebasNeue',
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: GritColors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'YOUR TRANSFORMATION BEGINS NOW',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: const Color(0xFFD97B3A), // mutedOrange
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Next Steps Card
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C34), // slateGray
                          border: Border.all(color: const Color(0xFF4A90E2).withOpacity(0.5), width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NEXT STEPS',
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: GritColors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _NextStepItem(
                              number: '1',
                              title: 'CHECK YOUR EMAIL',
                              description: 'Your ebook and access details are waiting',
                            ),
                            const SizedBox(height: 16),
                            _NextStepItem(
                              number: '2',
                              title: 'ACCESS YOUR CONTENT',
                              description: 'Visit the Ebooks section to download your Winter Arc guide',
                            ),
                            const SizedBox(height: 16),
                            _NextStepItem(
                              number: '3',
                              title: 'JOIN THE COMMUNITY',
                              description: 'Connect with other warriors in the Programs section (launches Nov 17)',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Motivational Quote
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD97B3A).withOpacity(0.5), width: 2),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.format_quote,
                              color: const Color(0xFFD97B3A),
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'The difference between who you are and who you want to be is what you do.',
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: GritColors.white,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Action Buttons
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),
                                foregroundColor: GritColors.black,
                                shape: const BeveledRectangleBorder(),
                                elevation: 8,
                              ),
                              onPressed: () => context.go('/ebooks'),
                              child: Text(
                                'ACCESS YOUR EBOOK',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: GritColors.white,
                                side: BorderSide(color: GritColors.white.withOpacity(0.3), width: 2),
                                shape: const BeveledRectangleBorder(),
                              ),
                              onPressed: () => context.go('/programs'),
                              child: Text(
                                'VIEW PROGRAMS',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => context.go('/'),
                            child: Text(
                              'Back to Home',
                              style: TextStyle(
                                fontSize: 14,
                                color: GritColors.grey,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NextStepItem extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _NextStepItem({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2), // frostBlue
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: GritColors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: GritColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: GritColors.grey,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

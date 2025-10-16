import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:alphagrit/app/theme/theme.dart';
import 'package:alphagrit/features/ebooks/ebooks_controllers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

// Winter Arc specific colors
class WinterArcColors {
  static const steelBlue = Color(0xFF1E3A5F);
  static const frostBlue = Color(0xFF4A90E2);
  static const mutedOrange = Color(0xFFD97B3A);
  static const darkGray = Color(0xFF1A1A1A);
  static const slateGray = Color(0xFF2C2C34);
}

class WinterArcLandingScreen extends ConsumerStatefulWidget {
  const WinterArcLandingScreen({super.key});

  @override
  ConsumerState<WinterArcLandingScreen> createState() => _WinterArcLandingState();
}

class _WinterArcLandingState extends ConsumerState<WinterArcLandingScreen> with SingleTickerProviderStateMixin {
  Timer? _countdownTimer;
  Duration _timeUntilLaunch = Duration.zero;
  bool _isLoading = false;
  int _currentCodeIndex = 0;
  Timer? _codeRotationTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final DateTime launchDate = DateTime.utc(2024, 11, 17);
  final DateTime endDate = DateTime.utc(2025, 2, 9, 23, 59, 59);

  final List<String> winterArcCode = [
    'DISCIPLINE.',
    'SACRIFICE.',
    'SILENCE.',
    'OVERCOMING.',
    'CLARITY.',
    'RESILIENCE.',
  ];

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
    _codeRotationTimer = Timer.periodic(const Duration(seconds: 3), (_) => _rotateCode());

    // Pulse animation for CTA button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Check auth and load ebook
    Future.microtask(() {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        ref.read(ebookDetailProvider.notifier).load('winter-arc');
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _codeRotationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _updateCountdown() {
    final now = DateTime.now().toUtc();
    if (mounted) {
      setState(() {
        _timeUntilLaunch = launchDate.isAfter(now) ? launchDate.difference(now) : Duration.zero;
      });
    }
  }

  void _rotateCode() {
    if (mounted) {
      setState(() {
        _currentCodeIndex = (_currentCodeIndex + 1) % winterArcCode.length;
      });
    }
  }

  Future<void> _checkAuthAndProceed(VoidCallback onAuthenticated) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      // Not authenticated - redirect to login
      if (mounted) {
        context.push('/login');
      }
    } else {
      onAuthenticated();
    }
  }

  Future<void> _openCheckout(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open checkout')),
        );
      }
    }
  }

  Future<void> _handleEbookCheckout() async {
    await _checkAuthAndProceed(() async {
      if (_isLoading) return;
      setState(() => _isLoading = true);
      try {
        final ebookState = ref.read(ebookDetailProvider);
        final ebook = ebookState.value;
        if (ebook != null) {
          final url = await ref.read(ebookDetailProvider.notifier).checkoutEbook(ebook.id);
          await _openCheckout(url);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _handleBundleCheckout() async {
    await _checkAuthAndProceed(() async {
      if (_isLoading) return;
      setState(() => _isLoading = true);
      try {
        final ebookState = ref.read(ebookDetailProvider);
        final ebook = ebookState.value;
        if (ebook != null) {
          final url = await ref.read(ebookDetailProvider.notifier).checkoutCombo(ebook.id, tier: 'standard');
          await _openCheckout(url);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final now = DateTime.now().toUtc();
    final hasLaunched = now.isAfter(launchDate);
    final hasEnded = now.isAfter(endDate);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: GritColors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              WinterArcColors.darkGray,
              GritColors.black,
              WinterArcColors.steelBlue.withOpacity(0.3),
              GritColors.black,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Custom App Bar with transparency
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: true,
              centerTitle: true,
              title: Text(
                'WINTER ARC',
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 24,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: WinterArcColors.frostBlue.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  // HERO SECTION
                  Stack(
                    children: [
                      // Dark overlay with vignette
                      Container(
                        height: screenWidth > 600 ? 500 : 400,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.0,
                            colors: [
                              Colors.transparent,
                              GritColors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),

                      // Hero content
                      Container(
                        height: screenWidth > 600 ? 500 : 400,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Rotating Winter Arc Code
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 800),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.3),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                winterArcCode[_currentCodeIndex],
                                key: ValueKey(_currentCodeIndex),
                                style: TextStyle(
                                  fontFamily: 'BebasNeue',
                                  fontSize: screenWidth > 600 ? 32 : 24,
                                  color: WinterArcColors.frostBlue,
                                  letterSpacing: 4,
                                  fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Main headline
                            Text(
                              'TURN WINTER INTO\nYOUR STRONGEST SEASON',
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: screenWidth > 600 ? 58 : 42,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: GritColors.white,
                                shadows: [
                                  Shadow(
                                    color: GritColors.black,
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            // Subheadline
                            Text(
                              'YOUR WAR PLAN FOR DISCIPLINE, GRIT, AND TRANSFORMATION',
                              style: TextStyle(
                                fontSize: screenWidth > 600 ? 16 : 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                color: WinterArcColors.mutedOrange,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Date banner
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: WinterArcColors.steelBlue.withOpacity(0.3),
                                border: Border.all(color: WinterArcColors.frostBlue, width: 2),
                              ),
                              child: Text(
                                'NOV 17 → FEB 9, 2025  •  12 WEEKS',
                                style: TextStyle(
                                  fontSize: screenWidth > 600 ? 16 : 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                  color: GritColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Countdown section
                  if (!hasLaunched && !hasEnded)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            WinterArcColors.slateGray,
                            WinterArcColors.darkGray,
                          ],
                        ),
                        border: Border.all(color: WinterArcColors.frostBlue.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: WinterArcColors.frostBlue.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            t.winterArcCountdown,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: WinterArcColors.frostBlue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _CountdownBox(value: _timeUntilLaunch.inDays, label: 'DAYS'),
                              const SizedBox(width: 12),
                              _CountdownBox(value: _timeUntilLaunch.inHours % 24, label: 'HRS'),
                              const SizedBox(width: 12),
                              _CountdownBox(value: _timeUntilLaunch.inMinutes % 60, label: 'MIN'),
                            ],
                          ),
                        ],
                      ),
                    ),

                  if (hasEnded)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: WinterArcColors.slateGray,
                        border: Border.all(color: GritColors.grey, width: 2),
                      ),
                      child: Text(
                        t.winterArcEnded,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: GritColors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Principles Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.winterArcWhatYouGet,
                          style: TextStyle(
                            fontFamily: 'BebasNeue',
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: GritColors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Principle cards
                        _PrincipleCard(
                          icon: Icons.shield,
                          title: 'COMPLETE TRAINING METHODOLOGY',
                          description: t.winterArcBullet1,
                        ),
                        const SizedBox(height: 12),
                        _PrincipleCard(
                          icon: Icons.people_outline,
                          title: 'PRIVATE ACCOUNTABILITY',
                          description: t.winterArcBullet2,
                        ),
                        const SizedBox(height: 12),
                        _PrincipleCard(
                          icon: Icons.trending_up,
                          title: 'DAILY PROGRESS TRACKING',
                          description: t.winterArcBullet3,
                        ),
                        const SizedBox(height: 12),
                        _PrincipleCard(
                          icon: Icons.access_time,
                          title: 'TIME-LIMITED ACCESS',
                          description: t.winterArcBullet4,
                        ),
                      ],
                    ),
                  ),

                  // Pricing Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.winterArcChoosePath,
                          style: TextStyle(
                            fontFamily: 'BebasNeue',
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: GritColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'NO SOFT ENCOURAGEMENT. ONLY DIRECT CALLS TO RISE.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: WinterArcColors.mutedOrange,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Ebook Option
                        _PricingCard(
                          title: t.winterArcEbookOnly,
                          price: '\$27',
                          description: t.winterArcEbookDesc,
                          features: ['Instant Download', 'Full Training Guide', 'Nutrition Protocols'],
                          onPressed: _isLoading || hasEnded ? null : _handleEbookCheckout,
                          buttonLabel: t.buyNow,
                          isPrimary: false,
                        ),
                        const SizedBox(height: 20),

                        // Bundle Option (Featured)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: WinterArcColors.frostBlue, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: WinterArcColors.frostBlue.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: _PricingCard(
                            title: t.winterArcBundle,
                            badge: t.winterArcFeatured,
                            price: '\$97',
                            strikePrice: !hasLaunched ? '\$147 after Nov 17' : null,
                            description: t.winterArcBundleDesc,
                            features: [
                              'Everything in Ebook',
                              '12-Week Community Access',
                              'Daily Accountability',
                              'Progress Tracking',
                            ],
                            onPressed: _isLoading || hasEnded ? null : _handleBundleCheckout,
                            buttonLabel: hasLaunched ? t.joinCommunity : t.joinFoundingTeam,
                            isPrimary: true,
                            pulseAnimation: _pulseAnimation,
                          ),
                        ),

                        if (!hasLaunched)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              t.winterArcCommunityLaunches,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: GritColors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Footer
                  Container(
                    margin: const EdgeInsets.only(top: 32),
                    padding: const EdgeInsets.all(24),
                    color: WinterArcColors.darkGray,
                    child: Column(
                      children: [
                        Text(
                          t.winterArcFooter,
                          style: TextStyle(
                            fontSize: 12,
                            color: GritColors.grey,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'READY FOR YOUR ARC?',
                          style: TextStyle(
                            fontFamily: 'BebasNeue',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: WinterArcColors.frostBlue,
                          ),
                        ),
                      ],
                    ),
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

// Countdown box widget
class _CountdownBox extends StatelessWidget {
  final int value;
  final String label;

  const _CountdownBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: WinterArcColors.darkGray,
        border: Border.all(color: WinterArcColors.frostBlue, width: 2),
        boxShadow: [
          BoxShadow(
            color: WinterArcColors.frostBlue.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: WinterArcColors.frostBlue,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: GritColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Principle card widget
class _PrincipleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PrincipleCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WinterArcColors.slateGray,
        border: Border.all(color: GritColors.white.withOpacity(0.1), width: 2),
        boxShadow: [
          BoxShadow(
            color: GritColors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: WinterArcColors.frostBlue.withOpacity(0.2),
              border: Border.all(color: WinterArcColors.frostBlue, width: 2),
            ),
            child: Icon(
              icon,
              color: WinterArcColors.frostBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: GritColors.white,
                  ),
                ),
                const SizedBox(height: 8),
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
      ),
    );
  }
}

// Pricing card widget
class _PricingCard extends StatelessWidget {
  final String title;
  final String? badge;
  final String price;
  final String? strikePrice;
  final String description;
  final List<String> features;
  final VoidCallback? onPressed;
  final String buttonLabel;
  final bool isPrimary;
  final Animation<double>? pulseAnimation;

  const _PricingCard({
    required this.title,
    this.badge,
    required this.price,
    this.strikePrice,
    required this.description,
    required this.features,
    required this.onPressed,
    required this.buttonLabel,
    required this.isPrimary,
    this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPrimary
              ? [WinterArcColors.steelBlue.withOpacity(0.3), WinterArcColors.darkGray]
              : [WinterArcColors.slateGray, WinterArcColors.darkGray],
        ),
        border: Border.all(
          color: isPrimary ? WinterArcColors.frostBlue : GritColors.white.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: GritColors.white,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: WinterArcColors.mutedOrange,
                    border: Border.all(color: GritColors.white, width: 2),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: GritColors.black,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: isPrimary ? WinterArcColors.frostBlue : GritColors.white,
                ),
              ),
              if (strikePrice != null) ...[
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    strikePrice!,
                    style: TextStyle(
                      fontSize: 14,
                      color: GritColors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: GritColors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isPrimary ? WinterArcColors.frostBlue : WinterArcColors.mutedOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: GritColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrimary ? WinterArcColors.frostBlue : GritColors.red,
                foregroundColor: isPrimary ? GritColors.black : GritColors.white,
                shape: const BeveledRectangleBorder(),
                elevation: isPrimary ? 8 : 4,
                shadowColor: isPrimary ? WinterArcColors.frostBlue.withOpacity(0.5) : null,
              ),
              onPressed: onPressed,
              child: Text(
                buttonLabel.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (pulseAnimation != null && isPrimary) {
      return ScaleTransition(
        scale: pulseAnimation!,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

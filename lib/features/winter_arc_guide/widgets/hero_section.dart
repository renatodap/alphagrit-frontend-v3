import 'package:flutter/material.dart';
import '../winter_arc_theme.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = WinterArcTheme.isMobile(context);

    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: WinterArcTheme.heroGradient,
        image: DecorationImage(
          image: const AssetImage('assets/images/hero_placeholder.png'),
          fit: BoxFit.cover,
          opacity: 0.15,
          onError: (exception, stackTrace) {
            // Fallback if image doesn't exist
          },
        ),
      ),
      child: Stack(
        children: [
          // Overlay gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  WinterArcTheme.black.withOpacity(0.7),
                  WinterArcTheme.charcoal.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // Content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingXXL,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main title
                  Text(
                    'WINTER ARC',
                    style: isMobile
                        ? WinterArcTheme.heroTitleMobile
                        : WinterArcTheme.heroTitle,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isMobile ? WinterArcTheme.spacingS : WinterArcTheme.spacingM),

                  // Ice blue accent line
                  Container(
                    width: isMobile ? 100 : 150,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: WinterArcTheme.accentGradient,
                    ),
                  ),

                  SizedBox(height: isMobile ? WinterArcTheme.spacingM : WinterArcTheme.spacingL),

                  // Subtitle
                  Text(
                    'Turn Winter Into Your Strongest Season',
                    style: isMobile
                        ? WinterArcTheme.sectionTitleMobile
                        : WinterArcTheme.sectionTitle,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isMobile ? WinterArcTheme.spacingL : WinterArcTheme.spacingXL),

                  // Description
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Text(
                      'Winter is not an enemy. It\'s an invitation to self-knowledge, to unwavering discipline, and to the construction of an inner fortress that will serve you in all seasons of life.',
                      style: isMobile
                          ? WinterArcTheme.bodyLargeMobile
                          : WinterArcTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: isMobile ? WinterArcTheme.spacingXL : WinterArcTheme.spacingXXL),

                  // CTA Button
                  _BuildCTAButton(isMobile: isMobile),
                ],
              ),
            ),
          ),

          // Scroll indicator
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: _ScrollIndicator(),
          ),
        ],
      ),
    );
  }
}

class _BuildCTAButton extends StatelessWidget {
  final bool isMobile;

  const _BuildCTAButton({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Scroll to first section
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? WinterArcTheme.spacingL : WinterArcTheme.spacingXL,
          vertical: isMobile ? WinterArcTheme.spacingS : WinterArcTheme.spacingM,
        ),
        decoration: BoxDecoration(
          gradient: WinterArcTheme.accentGradient,
          borderRadius: BorderRadius.circular(WinterArcTheme.radiusM),
          boxShadow: WinterArcTheme.buttonShadow,
        ),
        child: Text(
          'BEGIN YOUR WINTER ARC',
          style: WinterArcTheme.buttonText.copyWith(
            fontSize: isMobile ? 14 : 16,
          ),
        ),
      ),
    );
  }
}

class _ScrollIndicator extends StatefulWidget {
  @override
  State<_ScrollIndicator> createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<_ScrollIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Column(
            children: [
              Text(
                'SCROLL',
                style: WinterArcTheme.navText.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.keyboard_arrow_down,
                color: WinterArcTheme.iceBlue,
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }
}

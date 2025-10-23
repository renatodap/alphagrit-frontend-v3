import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../winter_arc_theme.dart';

/// Paywall overlay that shows when user doesn't have access
/// Blurs the content behind it and shows purchase options
class PaywallOverlay extends StatelessWidget {
  final String contentType; // 'ebook' or 'community'

  const PaywallOverlay({
    super.key,
    this.contentType = 'ebook',
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = WinterArcTheme.isMobile(context);

    return Container(
      color: Colors.black.withOpacity(0.95),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 20 : 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lock icon
                Icon(
                  Icons.lock,
                  size: 80,
                  color: WinterArcTheme.iceBlue,
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  contentType == 'ebook'
                      ? 'EBOOK ACCESS REQUIRED'
                      : 'COMMUNITY ACCESS REQUIRED',
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: WinterArcTheme.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  contentType == 'ebook'
                      ? 'This interactive Winter Arc guide is available to purchasers only. Choose your path below:'
                      : 'The Winter Arc community features are available to community members only. Join now:',
                  style: TextStyle(
                    fontSize: 16,
                    color: WinterArcTheme.lightGray,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Pricing options
                if (contentType == 'ebook') ...[
                  // Option 1: Ebook Only
                  _PricingOptionCard(
                    title: 'EBOOK ONLY',
                    price: '\$27',
                    description: 'Get instant access to the interactive guide',
                    features: [
                      'Complete Training Guide',
                      'Nutrition Protocols',
                      'Lifetime Access',
                    ],
                    onPressed: () => context.push('/winter-arc'),
                    buttonLabel: 'BUY EBOOK',
                    isPrimary: false,
                  ),
                  const SizedBox(height: 16),

                  // Option 2: Bundle
                  _PricingOptionCard(
                    title: 'EBOOK + COMMUNITY',
                    price: '\$97',
                    badge: 'BEST VALUE',
                    description: 'Everything + community + tracking',
                    features: [
                      'Everything in Ebook',
                      '12-Week Community Access',
                      'Progress Tracking',
                      'Daily Accountability',
                    ],
                    onPressed: () => context.push('/winter-arc'),
                    buttonLabel: 'GET BUNDLE',
                    isPrimary: true,
                  ),
                  const SizedBox(height: 16),

                  // Option 3: Premium
                  _PricingOptionCard(
                    title: 'EBOOK + COMMUNITY + WAGNER',
                    price: '\$197',
                    badge: 'ELITE',
                    description: 'Everything + Wagner-guaranteed responses',
                    features: [
                      'Everything in Bundle',
                      'Guaranteed Wagner Responses',
                      'Priority Support',
                      'Premium Badge',
                    ],
                    onPressed: () => context.push('/winter-arc'),
                    buttonLabel: 'GET COACHING',
                    isPrimary: false,
                    isPremium: true,
                  ),
                ] else ...[
                  // Community options only
                  _PricingOptionCard(
                    title: 'EBOOK + COMMUNITY',
                    price: '\$97',
                    badge: 'POPULAR',
                    description: 'Community access + ebook + tracking',
                    features: [
                      'Complete Ebook',
                      '12-Week Community Access',
                      'Progress Tracking',
                      'Daily Accountability',
                    ],
                    onPressed: () => context.push('/winter-arc'),
                    buttonLabel: 'JOIN COMMUNITY',
                    isPrimary: true,
                  ),
                  const SizedBox(height: 16),

                  _PricingOptionCard(
                    title: 'EBOOK + COMMUNITY + WAGNER',
                    price: '\$197',
                    badge: 'ELITE',
                    description: 'Everything + Wagner-guaranteed responses',
                    features: [
                      'Everything Above',
                      'Guaranteed Wagner Responses',
                      'Priority Support',
                      'Premium Badge',
                    ],
                    onPressed: () => context.push('/winter-arc'),
                    buttonLabel: 'GET ELITE ACCESS',
                    isPrimary: false,
                    isPremium: true,
                  ),
                ],

                const SizedBox(height: 32),

                // Back button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'GO BACK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: WinterArcTheme.gray,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pricing option card for paywall
class _PricingOptionCard extends StatelessWidget {
  final String title;
  final String? badge;
  final String price;
  final String description;
  final List<String> features;
  final VoidCallback onPressed;
  final String buttonLabel;
  final bool isPrimary;
  final bool isPremium;

  const _PricingOptionCard({
    required this.title,
    this.badge,
    required this.price,
    required this.description,
    required this.features,
    required this.onPressed,
    required this.buttonLabel,
    required this.isPrimary,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    Color accentColor = isPremium
        ? const Color(0xFFD97B3A) // mutedOrange
        : isPrimary
            ? WinterArcTheme.iceBlue
            : WinterArcTheme.gray;

    Color backgroundColor = isPremium
        ? const Color(0xFFD97B3A).withOpacity(0.1)
        : isPrimary
            ? WinterArcTheme.iceBlue.withOpacity(0.1)
            : WinterArcTheme.charcoal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: isPrimary || isPremium
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: WinterArcTheme.white,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: WinterArcTheme.black,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Price
          Text(
            price,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: WinterArcTheme.lightGray,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Features
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: WinterArcTheme.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),

          // Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: WinterArcTheme.black,
                elevation: isPrimary || isPremium ? 8 : 4,
                shadowColor: accentColor.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onPressed,
              child: Text(
                buttonLabel.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alphagrit/app/theme/theme.dart';
import 'package:alphagrit/features/profile/my_content_controllers.dart';
import 'package:alphagrit/features/navigation/app_navigation.dart';
import 'package:alphagrit/domain/models/ebook.dart';
import 'package:alphagrit/domain/models/program.dart';
import 'package:alphagrit/domain/models/profile.dart';
import 'package:alphagrit/app/providers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// My Content screen - shows user's purchased ebooks and community access
/// Mobile-first design with responsive layout for desktop
class MyContentScreen extends ConsumerWidget {
  const MyContentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final myContentAsync = ref.watch(myContentProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: GritColors.black,
      appBar: AuthAwareAppBar(
        title: 'My Content',
        showBackButton: true,
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 768
          ? MobileBottomNav(
              currentIndex: 1, // My Content is index 1
              onTap: (index) {
                userAsync.whenData((user) {
                  if (user != null) {
                    switch (index) {
                      case 0:
                        context.go('/');
                        break;
                      case 1:
                        // Already on My Content, do nothing
                        break;
                      case 2:
                        context.push('/settings');
                        break;
                    }
                  }
                });
              },
            )
          : null,
      body: myContentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: GritColors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Failed to load your content',
                  style: TextStyle(
                    color: GritColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(color: GritColors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(myContentProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: GritColors.black,
                  ),
                  child: const Text('RETRY'),
                ),
              ],
            ),
          ),
        ),
        data: (myContent) {
          if (!myContent.hasContent) {
            return _EmptyContentView();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User profile header with Winter Arc tier badge
                _ProfileHeader(profile: myContent.profile),
                const SizedBox(height: 32),

                // Community Access section
                if (myContent.enrolledPrograms.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Community Access',
                    icon: Icons.groups,
                  ),
                  const SizedBox(height: 12),
                  ...myContent.enrolledPrograms.map(
                    (program) => _ProgramCard(
                      program: program,
                      tier: myContent.profile.winterArcTier,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // My Ebooks section
                if (myContent.ownedEbooks.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'My Ebooks',
                    icon: Icons.library_books,
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive grid: 2 columns on mobile, 3-4 on desktop
                      final isDesktop = constraints.maxWidth > 768;
                      final crossAxisCount = isDesktop ? 4 : 2;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: myContent.ownedEbooks.length,
                        itemBuilder: (context, index) {
                          final ebook = myContent.ownedEbooks[index];
                          return _EbookCard(ebook: ebook);
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Profile header with name and Winter Arc tier badge
class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final displayName = profile.name ?? profile.userId.split('@').first;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    final tier = profile.winterArcTier;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E3A5F).withOpacity(0.3),
            const Color(0xFF2C2C34),
          ],
        ),
        border: Border.all(color: const Color(0xFF4A90E2).withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFF4A90E2),
            child: Text(
              initial,
              style: TextStyle(
                color: GritColors.black,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Name and tier
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.toUpperCase(),
                  style: TextStyle(
                    color: GritColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'BebasNeue',
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                if (tier != null) _TierBadge(tier: tier),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Winter Arc tier badge
class _TierBadge extends StatelessWidget {
  final String tier;

  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    final isPremium = tier == 'premium';
    final color = isPremium ? const Color(0xFFFFD700) : const Color(0xFF4A90E2);
    final label = isPremium ? 'PREMIUM' : 'STANDARD';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPremium ? Icons.star : Icons.verified,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header with icon
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4A90E2), size: 28),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: GritColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: 'BebasNeue',
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

/// Program/Community card
class _ProgramCard extends StatelessWidget {
  final Program program;
  final String? tier;

  const _ProgramCard({
    required this.program,
    this.tier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C34),
        border: Border.all(color: const Color(0xFF4A90E2).withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: () => context.push('/community/feed?programId=${program.id}&programTitle=${Uri.encodeComponent(program.title)}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Program icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.2),
                  border: Border.all(color: const Color(0xFF4A90E2), width: 2),
                ),
                child: Icon(Icons.groups, color: const Color(0xFF4A90E2), size: 32),
              ),
              const SizedBox(width: 16),

              // Program details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.title.toUpperCase(),
                      style: TextStyle(
                        color: GritColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'BebasNeue',
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      program.description,
                      style: TextStyle(
                        color: GritColors.grey,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tier != null) ...[
                      const SizedBox(height: 8),
                      _TierBadge(tier: tier!),
                    ],
                  ],
                ),
              ),

              // Arrow
              Icon(Icons.arrow_forward_ios, color: GritColors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ebook card for grid
class _EbookCard extends StatelessWidget {
  final Ebook ebook;

  const _EbookCard({required this.ebook});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/ebooks/${ebook.slug}'),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C34),
          border: Border.all(color: const Color(0xFF4A90E2).withOpacity(0.3), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover placeholder
            Expanded(
              child: Container(
                color: const Color(0xFF1E3A5F).withOpacity(0.3),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.menu_book,
                        color: const Color(0xFF4A90E2).withOpacity(0.5),
                        size: 48,
                      ),
                    ),
                    // Owned badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'OWNED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                ebook.title,
                style: TextStyle(
                  color: GritColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state when user has no content
class _EmptyContentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              color: GritColors.grey.withOpacity(0.5),
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'NO CONTENT YET',
              style: TextStyle(
                color: GritColors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontFamily: 'BebasNeue',
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start your journey by purchasing your first ebook or joining the Winter Arc community.',
              style: TextStyle(
                color: GritColors.grey,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: GritColors.black,
                  shape: const BeveledRectangleBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => context.push('/winter-arc'),
                child: const Text(
                  'EXPLORE WINTER ARC',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.push('/ebooks'),
              child: Text(
                'Browse Ebooks',
                style: TextStyle(
                  color: const Color(0xFF4A90E2),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alphagrit/app/theme/theme.dart';
import 'package:alphagrit/app/providers.dart';
import 'package:alphagrit/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Auth-aware app bar that shows appropriate actions based on user state
class AuthAwareAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const AuthAwareAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final isEnglish = currentLocale.languageCode == 'en';
    final userAsync = ref.watch(currentUserProvider);

    return AppBar(
      backgroundColor: GritColors.black,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      title: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'BebasNeue',
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
      actions: [
        // Language switcher
        IconButton(
          onPressed: () {
            final newLocale = isEnglish ? const Locale('pt') : const Locale('en');
            ref.read(localeProvider.notifier).setLocale(newLocale);
          },
          tooltip: isEnglish ? 'Mudar para Português' : 'Switch to English',
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEnglish ? '🇧🇷' : '🇺🇸',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
              Text(
                isEnglish ? 'PT' : 'EN',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: GritColors.white,
                ),
              ),
            ],
          ),
        ),

        // User menu or login button
        userAsync.when(
          data: (user) => user != null
              ? _UserMenu(user: user)
              : _LoginButton(),
          loading: () => const SizedBox(width: 48),
          error: (_, __) => _LoginButton(),
        ),
      ],
    );
  }
}

/// Login button for unauthenticated users
class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: () => context.push('/login'),
      child: Text(
        t.login.toUpperCase(),
        style: TextStyle(
          color: GritColors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// User menu dropdown for authenticated users
class _UserMenu extends ConsumerWidget {
  final User user;

  const _UserMenu({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    // Get user email (first part before @)
    final displayName = user.email?.split('@').first ?? 'User';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return PopupMenuButton<String>(
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: const Color(0xFF4A90E2),
        child: Text(
          initial,
          style: TextStyle(
            color: GritColors.black,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
      color: const Color(0xFF2C2C34),
      onSelected: (value) async {
        switch (value) {
          case 'my_content':
            context.push('/my-content');
            break;
          case 'settings':
            context.push('/settings');
            break;
          case 'logout':
            final authService = ref.read(authServiceProvider);
            await authService.signOut();
            if (context.mounted) {
              context.go('/');
            }
            break;
        }
      },
      itemBuilder: (context) => [
        // User email header
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  color: GritColors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              Text(
                user.email ?? '',
                style: TextStyle(
                  color: GritColors.grey,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Divider(color: GritColors.grey.withOpacity(0.3), height: 1),
            ],
          ),
        ),

        // My Content
        PopupMenuItem<String>(
          value: 'my_content',
          child: Row(
            children: [
              Icon(Icons.library_books, color: GritColors.white, size: 18),
              const SizedBox(width: 12),
              Text(
                t.myContent,
                style: TextStyle(color: GritColors.white, fontSize: 14),
              ),
            ],
          ),
        ),

        // Settings
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, color: GritColors.white, size: 18),
              const SizedBox(width: 12),
              Text(
                t.settings,
                style: TextStyle(color: GritColors.white, fontSize: 14),
              ),
            ],
          ),
        ),

        // Logout
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: GritColors.red, size: 18),
              const SizedBox(width: 12),
              Text(
                t.logout,
                style: TextStyle(color: GritColors.red, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Mobile-first bottom navigation bar (shows on mobile/tablet)
class MobileBottomNav extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MobileBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) => user != null ? _buildAuthenticatedNav(context) : _buildGuestNav(context),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _buildGuestNav(context),
    );
  }

  Widget _buildAuthenticatedNav(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1A1A1A),
      selectedItemColor: const Color(0xFF4A90E2),
      unselectedItemColor: GritColors.grey,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 10,
      ),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: t.home.toUpperCase(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.library_books),
          label: t.myContent.toUpperCase(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: t.account.toUpperCase(),
        ),
      ],
    );
  }

  Widget _buildGuestNav(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    // Guest nav only has 2 items, so clamp currentIndex to valid range
    final safeIndex = currentIndex.clamp(0, 1);
    return BottomNavigationBar(
      currentIndex: safeIndex,
      onTap: onTap, // Use the parameter instead of hardcoded navigation
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1A1A1A),
      selectedItemColor: const Color(0xFF4A90E2),
      unselectedItemColor: GritColors.grey,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: t.home.toUpperCase(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.login),
          label: t.login.toUpperCase(),
        ),
      ],
    );
  }
}

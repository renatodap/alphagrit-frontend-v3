import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alphagrit/features/home/home_screen.dart';
import 'package:alphagrit/features/ebooks/ebooks_list_screen.dart';
import 'package:alphagrit/features/ebooks/ebook_detail_screen.dart';
import 'package:alphagrit/features/programs/programs_list_screen.dart';
import 'package:alphagrit/features/programs/program_detail_screen.dart';
import 'package:alphagrit/features/store/store_screen.dart';
import 'package:alphagrit/features/metrics/metrics_screen.dart';
import 'package:alphagrit/features/profile/settings_screen.dart';
import 'package:alphagrit/features/admin/admin_dashboard_screen.dart';
import 'package:alphagrit/features/legal/privacy_screen.dart';
import 'package:alphagrit/features/legal/terms_screen.dart';
import 'package:alphagrit/features/auth/login_screen.dart';
import 'package:alphagrit/features/winter_arc/winter_arc_landing.dart';
import 'package:alphagrit/features/winter_arc_guide/winter_arc_guide_screen.dart';
import 'package:alphagrit/features/checkout/checkout_success_screen.dart';
import 'package:alphagrit/features/checkout/checkout_cancel_screen.dart';
import 'package:alphagrit/features/community/community_feed_screen.dart';
import 'package:alphagrit/features/community/create_post_screen.dart';
import 'package:alphagrit/features/community/post_detail_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/winter-arc', builder: (context, state) => const WinterArcLandingScreen()),
    GoRoute(path: '/winter-arc-guide', builder: (context, state) => const WinterArcGuideScreen()),
    GoRoute(path: '/success', builder: (context, state) => const CheckoutSuccessScreen()),
    GoRoute(path: '/cancel', builder: (context, state) => const CheckoutCancelScreen()),
    GoRoute(path: '/ebooks', builder: (context, state) => const EbooksListScreen()),
    GoRoute(
      path: '/ebooks/:slug',
      builder: (context, state) => EbookDetailScreen(slug: state.pathParameters['slug']!),
    ),
    GoRoute(path: '/programs', builder: (context, state) => const ProgramsListScreen()),
    GoRoute(
      path: '/programs/:id',
      builder: (context, state) => ProgramDetailScreen(programId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(path: '/store', builder: (context, state) => const StoreScreen()),
    GoRoute(path: '/metrics', builder: (context, state) => const MetricsScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
    GoRoute(path: '/legal/privacy', builder: (context, state) => const PrivacyScreen()),
    GoRoute(path: '/legal/terms', builder: (context, state) => const TermsScreen()),
    // Community routes
    GoRoute(
      path: '/community/feed',
      builder: (context, state) {
        final programId = int.parse(state.uri.queryParameters['programId'] ?? '1');
        final programTitle = state.uri.queryParameters['programTitle'] ?? 'Community';
        return CommunityFeedScreen(programId: programId, programTitle: programTitle);
      },
    ),
    GoRoute(
      path: '/community/create-post',
      builder: (context, state) {
        final programId = int.parse(state.uri.queryParameters['programId'] ?? '1');
        return CreatePostScreen(programId: programId);
      },
    ),
    GoRoute(
      path: '/community/post/:postId',
      builder: (context, state) {
        final postId = int.parse(state.pathParameters['postId']!);
        return PostDetailScreen(postId: postId);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(body: Center(child: Text(state.error.toString()))),
);


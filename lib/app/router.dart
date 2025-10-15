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

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
  ],
  errorBuilder: (context, state) => Scaffold(body: Center(child: Text(state.error.toString()))),
);


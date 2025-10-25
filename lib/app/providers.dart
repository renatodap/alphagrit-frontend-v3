import 'dart:ui';

import 'package:alphagrit/infra/api/api_client.dart';
import 'package:alphagrit/infra/api/waitlist_api.dart';
import 'package:alphagrit/data/repositories/winter_arc_repository.dart';
import 'package:alphagrit/data/repositories/admin_repository.dart';
import 'package:alphagrit/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Locale state for i18n toggle; defaults to device locale.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => PlatformDispatcher.instance.locale;

  void setLocale(Locale locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() => LocaleNotifier());

// ApiClient bound to current locale and auth state
// Recreates when user logs in/out OR changes language
final apiClientProvider = FutureProvider<ApiClient>((ref) async {
  final locale = ref.watch(localeProvider);
  // Watch auth state to recreate client when user logs in/out
  ref.watch(currentUserProvider);
  return ApiClient.create(locale);
});

// Simple API wrappers
final waitlistApiProvider = Provider<WaitlistApi>((ref) {
  final apiClientAsync = ref.watch(apiClientProvider);
  return apiClientAsync.when(
    data: (client) => WaitlistApi(client.dio),
    loading: () => throw StateError('WaitlistApi not ready yet'),
    error: (err, stack) => throw err,
  );
});

// Winter Arc Repository - Fixed to handle async properly
final winterArcRepositoryProvider = Provider<WinterArcRepository?>((ref) {
  final apiClientAsync = ref.watch(apiClientProvider);

  // Return null if still loading or error, repository if loaded
  return apiClientAsync.when(
    data: (client) => WinterArcRepository(client.dio),
    loading: () => null,  // Still loading, return null
    error: (err, stack) => null,  // Error, return null
  );
});

// Admin Repository - Fixed to handle async properly
final adminRepositoryProvider = Provider<AdminRepository?>((ref) {
  final apiClientAsync = ref.watch(apiClientProvider);

  // Return null if still loading or error, repository if loaded
  return apiClientAsync.when(
    data: (client) => AdminRepository(client.dio),
    loading: () => null,  // Still loading, return null
    error: (err, stack) => null,  // Error, return null
  );
});

// Auth Service - Provides comprehensive authentication with error handling
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((data) => data.session?.user);
});

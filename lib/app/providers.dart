import 'dart:ui';

import 'package:alphagrit/infra/api/api_client.dart';
import 'package:alphagrit/infra/api/waitlist_api.dart';
import 'package:alphagrit/data/repositories/winter_arc_repository.dart';
import 'package:alphagrit/data/repositories/admin_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Locale state for i18n toggle; defaults to device locale.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => PlatformDispatcher.instance.locale;

  void setLocale(Locale locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() => LocaleNotifier());

// ApiClient bound to current locale (for Accept-Language header)
final apiClientProvider = FutureProvider<ApiClient>((ref) async {
  final locale = ref.watch(localeProvider);
  return ApiClient.create(locale);
});

// Simple API wrappers
final waitlistApiProvider = Provider<WaitlistApi>((ref) {
  final dio = ref.watch(apiClientProvider).value!.dio;
  return WaitlistApi(dio);
});

// Winter Arc Repository
final winterArcRepositoryProvider = Provider<WinterArcRepository?>((ref) {
  final apiClient = ref.watch(apiClientProvider).value;
  if (apiClient == null) return null;
  return WinterArcRepository(apiClient.dio);
});

// Admin Repository
final adminRepositoryProvider = Provider<AdminRepository?>((ref) {
  final apiClient = ref.watch(apiClientProvider).value;
  if (apiClient == null) return null;
  return AdminRepository(apiClient.dio);
});

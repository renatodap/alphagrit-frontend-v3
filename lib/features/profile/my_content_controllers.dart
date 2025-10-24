import 'package:alphagrit/app/providers.dart';
import 'package:alphagrit/data/repositories/profile_repository.dart';
import 'package:alphagrit/features/ebooks/ebooks_controllers.dart';
import 'package:alphagrit/features/programs/programs_controllers.dart';
import 'package:alphagrit/domain/models/profile.dart';
import 'package:alphagrit/domain/models/ebook.dart';
import 'package:alphagrit/domain/models/program.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Profile repository provider
final profileRepoProvider = Provider<ProfileRepository?>((ref) {
  final apiClientAsync = ref.watch(apiClientProvider);
  return apiClientAsync.when(
    data: (client) => ProfileRepository(client.dio),
    loading: () => null,
    error: (err, stack) => null,
  );
});

/// User profile provider
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final repo = ref.watch(profileRepoProvider);
  if (repo == null) throw StateError('Profile repository not ready');
  return repo.me();
});

/// My Content data - combines profile, ebooks, and programs
class MyContentData {
  final UserProfile profile;
  final List<Ebook> ebooks;
  final List<Program> programs;

  MyContentData({
    required this.profile,
    required this.ebooks,
    required this.programs,
  });

  /// Get owned ebooks only
  List<Ebook> get ownedEbooks => ebooks.where((e) => e.owned ?? false).toList();

  /// Get enrolled programs only
  List<Program> get enrolledPrograms => programs.where((p) => p.member ?? false).toList();

  /// Check if user has any content
  bool get hasContent => ownedEbooks.isNotEmpty || enrolledPrograms.isNotEmpty;
}

/// My Content controller - fetches all user's purchased content
/// Uses existing providers from ebooks_controllers and programs_controllers
final myContentProvider = FutureProvider<MyContentData>((ref) async {
  final profileRepo = ref.watch(profileRepoProvider);
  final ebooksRepo = ref.watch(ebooksRepoProvider);
  final programsRepo = ref.watch(programsRepoProvider);

  // Check all repos are ready
  if (profileRepo == null) throw StateError('Profile repository not ready');
  if (ebooksRepo == null) throw StateError('Ebooks repository not ready');
  if (programsRepo == null) throw StateError('Programs repository not ready');

  // Fetch all data in parallel
  final results = await Future.wait([
    profileRepo.me(),
    ebooksRepo.list(),
    programsRepo.list(),
  ]);

  // Type-safe casting with validation (Bug #13 fix)
  if (results[0] is! UserProfile) {
    throw TypeError();
  }
  if (results[1] is! List<Ebook>) {
    throw TypeError();
  }
  if (results[2] is! List<Program>) {
    throw TypeError();
  }

  return MyContentData(
    profile: results[0] as UserProfile,
    ebooks: results[1] as List<Ebook>,
    programs: results[2] as List<Program>,
  );
});

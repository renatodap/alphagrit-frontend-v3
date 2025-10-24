import 'package:alphagrit/app/providers.dart';
import 'package:alphagrit/data/repositories/programs_repository.dart';
import 'package:alphagrit/domain/models/program.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final programsRepoProvider = Provider<ProgramsRepository?>((ref) {
  final apiClientAsync = ref.watch(apiClientProvider);
  return apiClientAsync.when(
    data: (client) => ProgramsRepository(client.dio),
    loading: () => null,
    error: (err, stack) => null,
  );
});

final programsListProvider = FutureProvider<List<Program>>((ref) async {
  final repo = ref.watch(programsRepoProvider);
  if (repo == null) throw StateError('Programs repository not ready');
  return repo.list();
});

class ProgramDetailController extends AutoDisposeAsyncNotifier<(Program, List<PostItem>)> {
  late final ProgramsRepository _repo;
  int? _programId;
  @override
  Future<(Program, List<PostItem>)> build() async {
    final repo = ref.watch(programsRepoProvider);
    if (repo == null) throw StateError('Programs repository not ready');
    _repo = repo;
    if (_programId == null) throw UnimplementedError('setProgramId before use');
    final program = await _repo.getProgram(_programId!);
    final posts = await _repo.listPosts(_programId!);
    return (program, posts);
  }

  void setProgramId(int id) => _programId = id;
  Future<void> refresh() async {
    if (_programId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final program = await _repo.getProgram(_programId!);
      final posts = await _repo.listPosts(_programId!);
      return (program, posts);
    });
  }

  Future<void> createPost({String? message, String? photoUrl, String visibility = 'public'}) async {
    if (_programId == null) return;
    await _repo.createPost(_programId!, message: message, photoUrl: photoUrl, visibility: visibility);
    await refresh();
  }

  Future<String> checkout({String tier = 'standard'}) async {
    if (_programId == null) return '';
    return _repo.checkout(_programId!, tier: tier);
  }
}

final programDetailProvider = AutoDisposeAsyncNotifierProvider<ProgramDetailController, (Program, List<PostItem>)>(
  () => ProgramDetailController(),
);


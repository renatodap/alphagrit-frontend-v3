import 'package:alphagrit/app/providers.dart';
import 'package:alphagrit/data/repositories/ebooks_repository.dart';
import 'package:alphagrit/domain/models/ebook.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ebooksRepoProvider = Provider<EbooksRepository?>((ref) {
  final apiClientAsync = ref.watch(apiClientProvider);
  return apiClientAsync.when(
    data: (client) => EbooksRepository(client.dio),
    loading: () => null,
    error: (err, stack) => null,
  );
});

final ebooksListProvider = FutureProvider<List<Ebook>>((ref) async {
  final repo = ref.watch(ebooksRepoProvider);
  if (repo == null) throw StateError('Ebooks repository not ready');
  return repo.list();
});

class EbookDetailController extends AutoDisposeAsyncNotifier<Ebook> {
  late final EbooksRepository _repo;
  @override
  Future<Ebook> build() async {
    final repo = ref.watch(ebooksRepoProvider);
    if (repo == null) throw StateError('Ebooks repository not ready');
    _repo = repo;
    // slug must be set via setSlug before use
    throw UnimplementedError('setSlug before use');
  }

  Future<void> load(String slug) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getBySlug(slug));
  }

  Future<String> checkoutEbook(int id) => _repo.checkoutEbook(id);
  Future<String> checkoutCombo(int ebookId, {String tier = 'standard'}) => _repo.checkoutCombo(ebookId, tier: tier);
}

final ebookDetailProvider = AutoDisposeAsyncNotifierProvider<EbookDetailController, Ebook>(() => EbookDetailController());


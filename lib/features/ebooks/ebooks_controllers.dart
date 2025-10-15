import 'package:alphagrit/app/providers.dart';
import 'package:alphagrit/data/repositories/ebooks_repository.dart';
import 'package:alphagrit/domain/models/ebook.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ebooksRepoProvider = Provider<EbooksRepository>((ref) {
  final dio = ref.watch(apiClientProvider).value!.dio;
  return EbooksRepository(dio);
});

final ebooksListProvider = FutureProvider<List<Ebook>>((ref) async {
  final repo = ref.watch(ebooksRepoProvider);
  return repo.list();
});

class EbookDetailController extends AutoDisposeAsyncNotifier<Ebook> {
  late final EbooksRepository _repo;
  @override
  Future<Ebook> build() async {
    _repo = ref.watch(ebooksRepoProvider);
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


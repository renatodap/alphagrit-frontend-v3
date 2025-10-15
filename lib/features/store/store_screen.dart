import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:alphagrit/app/theme/theme.dart';
import 'package:alphagrit/app/providers.dart';
import 'package:alphagrit/data/repositories/store_repository.dart';

final _storeRepoProvider = Provider<StoreRepository>((ref) {
  final dio = ref.watch(apiClientProvider).value!.dio;
  return StoreRepository(dio);
});

final _productsProvider = FutureProvider((ref) => ref.watch(_storeRepoProvider).list());

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final prods = ref.watch(_productsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.store.toUpperCase())),
      body: prods.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(e.toString())),
        data: (items) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .8),
          itemCount: items.length,
          itemBuilder: (_, i) => GritCard(child: Column(children: [
            const Expanded(child: Placeholder()),
            const SizedBox(height: 8),
            Text(items[i].name, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            GritButton(label: 'Amazon', onPressed: () async { await launchUrl(Uri.parse(items[i].amazonUrl), mode: LaunchMode.externalApplication); }),
          ])),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alphagrit/app/theme/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:alphagrit/features/ebooks/ebooks_controllers.dart';

class EbooksListScreen extends ConsumerWidget {
  const EbooksListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final ebooks = ref.watch(ebooksListProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.ebooks.toUpperCase())),
      body: ebooks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(e.toString())),
        data: (items) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: .72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          // +1 for the locally bundled Winter Arc ebook
          itemCount: items.length + 1,
          itemBuilder: (_, i) {
            // First tile: Winter Arc (local, free, no auth)
            if (i == 0) {
              return InkWell(
                onTap: () => context.push('/ebooks/winter-arc'),
                child: GritCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(child: Placeholder()),
                      const SizedBox(height: 8),
                      Text('Winter Arc', maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('Free', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              );
            }

            final eb = items[i - 1];
            return InkWell(
              onTap: () => context.push('/ebooks/${eb.slug}'),
              child: GritCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: Placeholder()),
                    const SizedBox(height: 8),
                    Text(eb.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${eb.priceCents} cents', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:alphagrit/app/theme/theme.dart';
import 'package:alphagrit/features/ebooks/ebooks_controllers.dart';

class EbookDetailScreen extends ConsumerStatefulWidget {
  final String slug;
  const EbookDetailScreen({super.key, required this.slug});
  @override
  ConsumerState<EbookDetailScreen> createState() => _EbookDetailState();
}

class _EbookDetailState extends ConsumerState<EbookDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ebookDetailProvider.notifier).load(widget.slug));
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final state = ref.watch(ebookDetailProvider);
    return Scaffold(
      appBar: AppBar(title: Text('${t.ebooks.toUpperCase()}: ${widget.slug}')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(e.toString())),
        data: (ebook) => Padding(
          padding: const EdgeInsets.all(16),
          child: (ebook.owned ?? false)
              ? const GritCard(child: Text('EBOOK CONTENT HERE'))
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.paywallMessage, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  GritButton(
                    label: t.buy,
                    onPressed: () async {
                      final url = await ref.read(ebookDetailProvider.notifier).checkoutEbook(ebook.id);
                      await _open(url);
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: GritButton(
                        label: t.buyCombo,
                        onPressed: () async {
                          final url = await ref.read(ebookDetailProvider.notifier).checkoutCombo(ebook.id, tier: 'standard');
                          await _open(url);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GritButton(
                        label: t.premium,
                        onPressed: () async {
                          final url = await ref.read(ebookDetailProvider.notifier).checkoutCombo(ebook.id, tier: 'premium');
                          await _open(url);
                        },
                      ),
                    ),
                  ]),
                ]),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:alphagrit/app/theme/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:alphagrit/app/providers.dart';
import 'package:alphagrit/data/repositories/metrics_repository.dart';
import 'package:alphagrit/domain/models/metric.dart';

final _metricsRepoProvider = Provider<MetricsRepository>((ref) {
  final dio = ref.watch(apiClientProvider).value!.dio;
  return MetricsRepository(dio);
});

final _metricsProvider = FutureProvider<List<Metric>>((ref) => ref.watch(_metricsRepoProvider).list());

class MetricsScreen extends ConsumerWidget {
  const MetricsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final metrics = ref.watch(_metricsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.metrics.toUpperCase())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.logEntry.toUpperCase(), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _MetricForm(onSaved: () => ref.refresh(_metricsProvider)),
          const SizedBox(height: 16),
          Expanded(
            child: metrics.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text(e.toString())),
              data: (items) => ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final m = items[i];
                  return GritCard(child: Text('${m.date}  •  ${m.weight ?? '-'}  •  ${m.bodyFat ?? '-'}%'));
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _MetricForm extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  const _MetricForm({required this.onSaved});
  @override
  ConsumerState<_MetricForm> createState() => _MetricFormState();
}

class _MetricFormState extends ConsumerState<_MetricForm> {
  final weightCtrl = TextEditingController();
  final bodyFatCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  bool saving = false;

  Future<void> _save(BuildContext context) async {
    setState(() => saving = true);
    try {
      final repo = ref.read(_metricsRepoProvider);
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final weight = double.tryParse(weightCtrl.text);
      final bodyFat = double.tryParse(bodyFatCtrl.text);
      await repo.create(date: date, weight: weight, bodyFat: bodyFat, note: noteCtrl.text);
      widget.onSaved();
      weightCtrl.clear();
      bodyFatCtrl.clear();
      noteCtrl.clear();
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(children: [
      Row(children: [
        Expanded(child: TextField(controller: weightCtrl, decoration: InputDecoration(labelText: t.weight))),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: bodyFatCtrl, decoration: InputDecoration(labelText: t.bodyFat))),
      ]),
      const SizedBox(height: 8),
      TextField(controller: noteCtrl, decoration: InputDecoration(labelText: t.note)),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: ElevatedButton(onPressed: saving ? null : () {}, child: Text(t.upload.toUpperCase()))),
        const SizedBox(width: 8),
        Expanded(child: ElevatedButton(onPressed: saving ? null : () => _save(context), child: Text(t.save.toUpperCase()))),
      ]),
    ]);
  }
}


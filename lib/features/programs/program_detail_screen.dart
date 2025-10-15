import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alphagrit/app/theme/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:alphagrit/features/programs/programs_controllers.dart';

class ProgramDetailScreen extends ConsumerStatefulWidget {
  final int programId;
  const ProgramDetailScreen({super.key, required this.programId});
  @override
  ConsumerState<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends ConsumerState<ProgramDetailScreen> {
  final ctrl = TextEditingController();
  bool privateToCoach = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(programDetailProvider.notifier);
    notifier.setProgramId(widget.programId);
    Future.microtask(() => notifier.refresh());
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final state = ref.watch(programDetailProvider);
    return Scaffold(
      appBar: AppBar(title: Text('${t.programs.toUpperCase()} #${widget.programId}')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(e.toString())),
        data: (data) {
          final program = data.$1;
          final posts = data.$2;
          return Column(children: [
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: GritCard(child: Text(error!, style: const TextStyle(color: Colors.red))),
              ),
            if ((program.member ?? false) == false)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Expanded(child: GritButton(label: t.joinProgram, onPressed: () async { final url = await ref.read(programDetailProvider.notifier).checkout(tier: 'standard'); await _open(url); })),
                  const SizedBox(width: 8),
                  Expanded(child: GritButton(label: t.upgradePremium, onPressed: () async { final url = await ref.read(programDetailProvider.notifier).checkout(tier: 'premium'); await _open(url); })),
                ]),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: true,
                itemCount: posts.length,
                itemBuilder: (_, i) {
                  final p = posts[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GritCard(child: Text((p.message ?? '') + ' — ' + p.visibility.toUpperCase())),
                  );
                },
              ),
            ),
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      decoration: InputDecoration(hintText: t.composePlaceholder),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: privateToCoach,
                    onChanged: (v) => setState(() => privateToCoach = v),
                  ),
                  Text(privateToCoach ? t.privateToCoach : t.public),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() => error = null);
                      try {
                        await ref.read(programDetailProvider.notifier).createPost(message: ctrl.text, visibility: privateToCoach ? 'private' : 'public');
                        ctrl.clear();
                      } catch (e) {
                        setState(() => error = e.toString());
                      }
                    },
                    child: Text(t.post.toUpperCase()),
                  ),
                ]),
              ]),
            ),
          ]);
        },
      ),
    );
  }
}


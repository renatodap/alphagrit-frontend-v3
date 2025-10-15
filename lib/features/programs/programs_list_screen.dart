import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:alphagrit/features/programs/programs_controllers.dart';
import 'package:go_router/go_router.dart';

class ProgramsListScreen extends ConsumerWidget {
  const ProgramsListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final programs = ref.watch(programsListProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.programs.toUpperCase())),
      body: programs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(e.toString())),
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) => ListTile(
            title: Text(items[i].title),
            subtitle: Text(items[i].description),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/programs/${items[i].id}'),
          ),
          separatorBuilder: (_, __) => const Divider(),
        ),
      ),
    );
  }
}


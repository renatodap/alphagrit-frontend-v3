import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:alphagrit/app/theme/theme.dart';
import 'package:alphagrit/app/providers.dart';
import 'package:alphagrit/data/repositories/profile_repository.dart';
import 'package:alphagrit/app/providers.dart' as providers;
import 'package:alphagrit/domain/models/profile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String units = 'kg';
  bool emailSummaries = false;
  bool replies = true;
  bool coachResponses = true;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final api = ref.watch(apiClientProvider).value;
    final profileRepo = api == null ? null : ProfileRepository(api.dio);
    return Scaffold(
      appBar: AppBar(title: Text(t.settings.toUpperCase())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GritCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.language.toUpperCase(), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Row(children: [
                ElevatedButton(onPressed: () { ref.read(providers.localeProvider.notifier).setLocale(const Locale('en')); if (profileRepo != null) { profileRepo.update(UserProfile(userId: '', language: 'en')); } }, child: const Text('EN')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () { ref.read(providers.localeProvider.notifier).setLocale(const Locale('pt')); if (profileRepo != null) { profileRepo.update(UserProfile(userId: '', language: 'pt')); } }, child: const Text('PT')),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          GritCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.units.toUpperCase(), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: units,
                items: [DropdownMenuItem(value: 'kg', child: Text(t.kg)), DropdownMenuItem(value: 'lb', child: Text(t.lb))],
                onChanged: (v) => setState(() => units = v ?? 'kg'),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          GritCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.notifications.toUpperCase(), style: Theme.of(context).textTheme.titleLarge),
              SwitchListTile(value: emailSummaries, onChanged: (v) => setState(() => emailSummaries = v), title: Text(t.emailSummaries)),
              SwitchListTile(value: replies, onChanged: (v) => setState(() => replies = v), title: Text(t.replies)),
              SwitchListTile(value: coachResponses, onChanged: (v) => setState(() => coachResponses = v), title: Text(t.coachResponses)),
              const SizedBox(height: 8),
              GritButton(label: t.save, onPressed: () {}),
            ]),
          ),
        ],
      ),
    );
  }
}


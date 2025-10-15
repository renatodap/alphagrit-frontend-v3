import 'package:flutter/material.dart';
import 'package:alphagrit/app/theme/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.appTitle.toUpperCase())),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.ctaSufferTransform, style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 16),
              GritButton(label: t.ebooks, onPressed: () => context.push('/ebooks')),
              const SizedBox(height: 8),
              GritButton(label: t.programs, onPressed: () => context.push('/programs')),
              const SizedBox(height: 8),
              GritButton(label: t.store, onPressed: () => context.push('/store')),
            ],
          ),
        ),
      ),
    );
  }
}



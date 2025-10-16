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
              const SizedBox(height: 24),

              // Winter Arc Featured Section
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: GritColors.red, width: 3),
                ),
                child: GritCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'WINTER ARC',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 36),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: GritColors.red,
                              border: Border.all(color: GritColors.white, width: 2),
                            ),
                            child: Text(
                              'NEW',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'NOV 17 → FEB 9 • 12 WEEKS',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: GritColors.grey),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t.winterArcHomeDesc,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      GritButton(
                        label: t.joinWinterArc,
                        onPressed: () => context.push('/winter-arc'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Regular Navigation
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



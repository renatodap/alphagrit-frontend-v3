import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:alphagrit/app/theme/theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.admin.toUpperCase())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: const [
            Expanded(child: GritCard(child: Text('Total Revenue'))),
            SizedBox(width: 12),
            Expanded(child: GritCard(child: Text('Paid Orders'))),
          ]),
          const SizedBox(height: 12),
          Expanded(child: GritCard(child: ListView(children: const [Text('Moderation Queue')]))),
        ]),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.privacyPolicy.toUpperCase())),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Privacy policy goes here. Explain data usage, storage, and rights.'),
      ),
    );
  }
}



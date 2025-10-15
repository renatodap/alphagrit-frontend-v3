import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.termsOfUse.toUpperCase())),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Terms of use go here. Include acceptable use and liabilities.'),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:alphagrit/app/theme/theme.dart';

class CheckoutCancelScreen extends StatelessWidget {
  const CheckoutCancelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.checkoutCanceled.toUpperCase()),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cancel Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: GritColors.grey, width: 3),
                    color: GritColors.greyDark,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 80,
                    color: GritColors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // Cancel Message
                Text(
                  t.checkoutCanceledTitle,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 42),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                GritCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.checkoutCanceledMessage,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.checkoutCanceledCta,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GritColors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                GritButton(
                  label: t.tryAgain,
                  onPressed: () => context.go('/winter-arc'),
                ),
                const SizedBox(height: 12),
                GritButton(
                  label: t.browsePrograms,
                  onPressed: () => context.go('/programs'),
                  inverted: true,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: Text(
                    t.backToHome,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.underline,
                          color: GritColors.grey,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

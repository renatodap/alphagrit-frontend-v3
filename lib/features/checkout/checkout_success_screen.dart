import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:alphagrit/app/theme/theme.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  const CheckoutSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.checkoutSuccess.toUpperCase()),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: GritColors.red, width: 3),
                    color: GritColors.greyDark,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: GritColors.red,
                  ),
                ),
                const SizedBox(height: 32),

                // Success Message
                Text(
                  t.checkoutSuccessTitle,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 42),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                GritCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.checkoutSuccessMessage,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.checkoutSuccessNextSteps,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. ${t.checkoutSuccessStep1}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '2. ${t.checkoutSuccessStep2}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '3. ${t.checkoutSuccessStep3}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                GritButton(
                  label: t.goToPrograms,
                  onPressed: () => context.go('/programs'),
                ),
                const SizedBox(height: 12),
                GritButton(
                  label: t.goToEbooks,
                  onPressed: () => context.go('/ebooks'),
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

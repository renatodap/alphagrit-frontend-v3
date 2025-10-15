import 'package:alphagrit/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Navigate to E-Books list', (tester) async {
    await tester.pumpWidget(const app.AlphaGritApp());
    await tester.pumpAndSettle();

    // Tap the E-Books CTA
    final ebooks = find.text('E-Books');
    expect(ebooks, findsOneWidget);
    await tester.tap(ebooks);
    await tester.pumpAndSettle();

    // Expect E-BOOKS AppBar title
    expect(find.text('E-BOOKS'), findsOneWidget);
  });
}

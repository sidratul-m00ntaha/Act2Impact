import 'package:act2impact/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows onboarding for a brand-new user', (tester) async {
    // Pretend the device has no saved data.
    SharedPreferences.setMockInitialValues({});

    // Local mode: widget tests have no Firebase environment.
    await tester.pumpWidget(const Act2ImpactApp(useFirebase: false));
    await tester.pumpAndSettle();

    expect(find.text('Act2Impact'), findsOneWidget);
    expect(find.text('Your anonymous name'), findsOneWidget);

    // The start button is below the fold; ListView builds lazily, so we
    // must scroll it into view before we can find it.
    await tester.scrollUntilVisible(find.text('Start my first act'), 200);
    expect(find.text('Start my first act'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskconnect/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build the login screen and trigger a frame.
    await tester.pumpWidget(const MyApp(isLogin: false));

    // Check if the login page displays necessary elements.
    expect(find.text('Login'),
        findsOneWidget); // Verify the 'Login' text is displayed
    expect(
        find.byType(TextFormField),
        findsNWidgets(
            2)); // Assuming there are two TextFields (username & password)

    // Enter text in the username and password fields.
    await tester.enterText(
        find.byKey(const Key('usernameKey')), 'test_user@icloud.com');
    await tester.enterText(find.byKey(const Key('passwordKey')), 'password123');

    // Tap the login button and trigger a frame.
    await tester.tap(find.byType(GestureDetector));
    await tester.pump();

    // Assuming after login success, there's a 'Welcome' text or some indicator.
    expect(find.text('Welcome'),
        findsOneWidget); // Verifies the login was successful and redirected to a welcome screen
  });
}

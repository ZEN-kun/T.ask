import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mobile/app/app.dart';
import 'package:task_mobile/core/constants/app_constants.dart';
import 'package:task_mobile/features/auth/providers/auth_provider.dart';

void main() {
  testWidgets('App renders splash screen with motto and navigates', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const TaskApp(),
      ),
    );

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.motto), findsOneWidget);

    // Drain the splash screen 2-second timer
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}

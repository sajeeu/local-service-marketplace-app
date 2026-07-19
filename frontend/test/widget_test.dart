import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/core/state/preferences_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots to foundation home shell', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const LocalServiceMarketplaceApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Foundation ready'), findsOneWidget);
    expect(find.text('Check API health'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

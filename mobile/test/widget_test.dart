import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akeep/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await Hive.initFlutter();
    await tester.pumpWidget(const MyApp(isDarkMode: true, isLoggedIn: false));
    await tester.pumpAndSettle();
    expect(find.byType(MyApp), findsOneWidget);
  });
}

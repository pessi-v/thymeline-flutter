import 'package:flutter_test/flutter_test.dart';

import 'package:thymeline/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ThymelineApp());

    // Verify that the app title is shown
    expect(find.text('Thymeline'), findsOneWidget);
  });
}

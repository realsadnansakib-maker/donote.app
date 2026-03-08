import 'package:flutter_test/flutter_test.dart';
import 'package:do_note/main.dart';

void main() {
  testWidgets('Do Note app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DoNoteApp());
    expect(find.text('Do Note'), findsOneWidget);
  });
}

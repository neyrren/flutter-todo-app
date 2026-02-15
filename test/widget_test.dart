// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/main.dart';

void main() {
  testWidgets('App shows empty state initially', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('My Todos'), findsOneWidget);
    expect(find.text('No todos yet!'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Can add a todo', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tap FAB to open add sheet
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Type a todo
    await tester.enterText(find.byType(TextField), 'Buy groceries');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Verify the todo appears
    expect(find.text('Buy groceries'), findsOneWidget);
    expect(find.text('No todos yet!'), findsNothing);
  });

  testWidgets('Can toggle a todo', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Add a todo
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Test todo');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Toggle the checkbox
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    // Verify it's checked
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isTrue);
  });
}

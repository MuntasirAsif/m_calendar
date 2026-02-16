import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_calendar/m_calendar.dart';

void main() {
  testWidgets('horizontal view scrolls to initial date by default', (
    WidgetTester tester,
  ) async {
    final selectedMonth = DateTime(2026, 2);
    final initialDate = DateTime(2026, 2, 15);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MCalendar.horizontal(
            selectedMonth: selectedMonth,
            onUserPicked: (_) {},
            initialDate: initialDate,
          ),
        ),
      ),
    );

    // let animations and post-frame callbacks run
    await tester.pumpAndSettle();

    final state = tester.state<ScrollableState>(
      find.byKey(const Key('horizontal_calendar_list')),
    );
    expect(state.position.pixels, closeTo((initialDate.day - 1) * 68.0, 0.1));
  });

  testWidgets('horizontal view does not auto scroll when disabled', (
    WidgetTester tester,
  ) async {
    final selectedMonth = DateTime(2026, 2);
    final initialDate = DateTime(2026, 2, 20);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MCalendar.horizontal(
            selectedMonth: selectedMonth,
            onUserPicked: (_) {},
            initialDate: initialDate,
            autoScroll: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final state = tester.state<ScrollableState>(
      find.byKey(const Key('horizontal_calendar_list')),
    );
    expect(state.position.pixels, 0.0);
  });
}

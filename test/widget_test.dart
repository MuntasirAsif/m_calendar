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

    final state = tester.state<ScrollableState>(find.byType(Scrollable));
    // itemExtent 68 (60 + 8 margin), minus 120 centering offset.
    final expected = (initialDate.day - 1) * 68.0 - 120;
    expect(state.position.pixels, closeTo(expected, 0.1));
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

    final state = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(state.position.pixels, 0.0);
  });

  testWidgets('monthly calendar fires callback with tapped date', (
    WidgetTester tester,
  ) async {
    List<DateTime>? picked;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MCalendar(
            selectedMonth: DateTime(2026, 3),
            onUserPicked: (dates) => picked = dates,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();

    expect(picked, isNotNull);
    expect(picked!.length, 1);
    expect(picked!.single, DateTime(2026, 3, 10));
  });

  testWidgets('monthly range selection returns sorted range', (
    WidgetTester tester,
  ) async {
    List<DateTime>? picked;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MCalendar(
            selectedMonth: DateTime(2026, 3),
            isRangeSelection: true,
            onUserPicked: (dates) => picked = dates,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap 15 first, then 10 — the range must still come out sorted.
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    expect(picked, isNull); // range not complete yet

    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();

    expect(picked, isNotNull);
    expect(picked!.length, 6); // Mar 10..15
    expect(picked!.first, DateTime(2026, 3, 10));
    expect(picked!.last, DateTime(2026, 3, 15));
  });

  testWidgets('weekly calendar builds and reports picked week', (
    WidgetTester tester,
  ) async {
    List<DateTime>? picked;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MCalendar.weekly(
            selectedMonth: DateTime(2023, 9),
            onUserPicked: (dates) => picked = dates,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('SEP'), findsOneWidget);
    // September 2023 needs 6 rows when weeks start on Saturday.
    expect(find.text('Week 6'), findsOneWidget);

    await tester.tap(find.textContaining('-').first);
    await tester.pumpAndSettle();

    expect(picked, isNotNull);
    expect(picked!.length, 1);
  });

  testWidgets('controller advances month and updates calendar view', (
    WidgetTester tester,
  ) async {
    final controller = MCalendarController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MCalendar.monthly(
            controller: controller,
            selectedMonth: DateTime(2026, 3),
            onUserPicked: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('March 2026'), findsOneWidget);

    controller.nextMonth();
    await tester.pumpAndSettle();
    expect(find.text('April 2026'), findsOneWidget);

    controller.previousMonth();
    await tester.pumpAndSettle();
    expect(find.text('March 2026'), findsOneWidget);
  });

  testWidgets('dayBuilder renders custom widget and passes DayState', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MCalendar.monthly(
            selectedMonth: DateTime(2026, 3),
            dayBuilder: (context, date, state) {
              if (date.day == 15) {
                return const Text('CustomDay15');
              }
              return null;
            },
            onUserPicked: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('CustomDay15'), findsOneWidget);
  });

  testWidgets('minDate prevents tapping disabled days', (
    WidgetTester tester,
  ) async {
    List<DateTime>? picked;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MCalendar(
            selectedMonth: DateTime(2026, 3),
            minDate: DateTime(2026, 3, 10),
            onUserPicked: (dates) => picked = dates,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Day 5 is disabled
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    expect(picked, isNull);

    // Day 12 is enabled
    await tester.tap(find.text('12'));
    await tester.pumpAndSettle();
    expect(picked, isNotNull);
    expect(picked!.single, DateTime(2026, 3, 12));
  });

  testWidgets(
    'horizontal view disables days outside initialDate/endDate range',
    (WidgetTester tester) async {
      // Widen the surface so the lazily-built horizontal list renders all days.
      tester.view.physicalSize = const Size(4000, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      DateTime? picked;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 2000,
              height: 100,
              child: MCalendar.horizontal(
                selectedMonth: DateTime(2026, 2),
                onUserPicked: (d) => picked = d,
                endDate: DateTime(2026, 2, 15),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();
      expect(picked, DateTime(2026, 2, 15));

      picked = null;
      await tester.tap(find.text('16'));
      await tester.pumpAndSettle();
      expect(picked, isNull);
    },
  );

  testWidgets(
    'monthly config propagation preserves range and enables new cells',
    (WidgetTester tester) async {
      List<DateTime>? picked;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MCalendar.monthly(
              selectedMonth: DateTime(2026, 3),
              isRangeSelection: true,
              onUserPicked: (dates) => picked = dates,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(picked, isNotNull);
      expect(picked!.first, DateTime(2026, 3, 12));
      expect(picked!.last, DateTime(2026, 3, 15));

      // Rebuild with a stricter minDate that disables day 12.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MCalendar.monthly(
              selectedMonth: DateTime(2026, 3),
              isRangeSelection: true,
              minDate: DateTime(2026, 3, 18),
              onUserPicked: (dates) => picked = dates,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Day 12 is now disabled and cannot start a new range.
      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();
      expect(picked, isNotNull);
      expect(picked!.first, DateTime(2026, 3, 12));

      // Day 20 is selectable and begins a new range.
      picked = null;
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
      expect(picked, isNull);

      await tester.tap(find.text('25'));
      await tester.pumpAndSettle();
      expect(picked, isNotNull);
      expect(picked!.first, DateTime(2026, 3, 20));
      expect(picked!.last, DateTime(2026, 3, 25));
    },
  );

  testWidgets('controller replacement attaches the new controller', (
    WidgetTester tester,
  ) async {
    final controllerA = MCalendarController();
    final controllerB = MCalendarController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MCalendar.monthly(
            controller: controllerA,
            selectedMonth: DateTime(2026, 3),
            onUserPicked: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('March 2026'), findsOneWidget);

    // Rebuild with controllerB.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MCalendar.monthly(
            controller: controllerB,
            selectedMonth: DateTime(2026, 3),
            onUserPicked: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    controllerB.setMonth(DateTime(2026, 8));
    await tester.pumpAndSettle();
    expect(find.text('August 2026'), findsOneWidget);

    // ControllerA should be detached and not driving the view.
    controllerA.setMonth(DateTime(2027, 12));
    await tester.pumpAndSettle();
    expect(find.text('August 2026'), findsOneWidget);

    controllerA.dispose();
    controllerB.dispose();
  });
}

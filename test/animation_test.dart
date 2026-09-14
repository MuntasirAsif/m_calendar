import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_calendar/m_calendar.dart';

/// The first animated cell container inside [finder].
Finder _firstCell(Finder calendar) =>
    find
        .descendant(of: calendar, matching: find.byType(AnimatedContainer))
        .first;

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('cells animate with a default CalendarAnimations config', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(
        MCalendar(
          selectedMonth: DateTime(2026, 3),
          animations: const CalendarAnimations(),
          onUserPicked: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cell = tester.widget<AnimatedContainer>(
      _firstCell(find.byType(MCalendar)),
    );
    expect(cell.duration, const Duration(milliseconds: 180));
  });

  testWidgets('cells are instant when animations is null', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(MCalendar(selectedMonth: DateTime(2026, 3), onUserPicked: (_) {})),
    );
    await tester.pumpAndSettle();

    final cell = tester.widget<AnimatedContainer>(
      _firstCell(find.byType(MCalendar)),
    );
    expect(cell.duration, Duration.zero);
  });

  testWidgets('cells are instant with CalendarAnimations.none', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(
        MCalendar(
          selectedMonth: DateTime(2026, 3),
          animations: CalendarAnimations.none,
          onUserPicked: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cell = tester.widget<AnimatedContainer>(
      _firstCell(find.byType(MCalendar)),
    );
    expect(cell.duration, Duration.zero);
  });

  testWidgets('reduce motion forces instant updates', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: host(
          MCalendar(
            selectedMonth: DateTime(2026, 3),
            animations: const CalendarAnimations(),
            onUserPicked: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cell = tester.widget<AnimatedContainer>(
      _firstCell(find.byType(MCalendar)),
    );
    expect(cell.duration, Duration.zero);
  });

  testWidgets('month change animates and settles without errors', (
    WidgetTester tester,
  ) async {
    final controller = MCalendarController();

    await tester.pumpWidget(
      host(
        MCalendar.monthly(
          controller: controller,
          selectedMonth: DateTime(2026, 3),
          animations: const CalendarAnimations(),
          onUserPicked: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('March 2026'), findsOneWidget);

    controller.nextMonth();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 125));

    // Mid-transition must not throw; the new month is already rendered.
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(find.text('April 2026'), findsOneWidget);
  });

  testWidgets('month change is instant when animations is null', (
    WidgetTester tester,
  ) async {
    final controller = MCalendarController();

    await tester.pumpWidget(
      host(
        MCalendar.monthly(
          controller: controller,
          selectedMonth: DateTime(2026, 3),
          onUserPicked: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    controller.nextMonth();
    await tester.pump();

    expect(find.text('April 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AnimatedSize is used when a size duration is configured', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(
        MCalendar.monthly(
          selectedMonth: DateTime(2026, 3),
          animations: const CalendarAnimations(),
          onUserPicked: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AnimatedSize), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
// The example dir has no pubspec of its own, so it is reached via the
// repository-relative path rather than a package: URI.
// ignore: avoid_relative_lib_imports
import '../example/lib/main.dart';
import 'package:m_calendar/m_calendar.dart';

/// Renders the full demo page from `example/lib/main.dart` on a large viewport
/// so every demo section is laid out on screen without needing to scroll.
Future<void> _pumpDemo(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1400, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

/// The [index]-th demo calendar in the page (single, range, weekly, horizontal).
Finder _calendar(int index) => find.byType(MCalendar).at(index);

/// The day-cell [label] inside the [index]-th demo calendar.
Finder _day(int index, String label) =>
    find.descendant(of: _calendar(index), matching: find.text(label));

/// True when [date] belongs to the same year/month as [month].
bool _sameMonth(DateTime month, DateTime date) =>
    month.year == date.year && month.month == date.month;

void main() {
  testWidgets('renders every demo section from the example page', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester);

    expect(find.byType(MCalendar), findsNWidgets(4));
    expect(
      find.text('Monthly — single selection + marked dates'),
      findsOneWidget,
    );
    expect(find.text('Monthly — range selection'), findsOneWidget);
    expect(find.text('Weekly — start day: Sunday'), findsOneWidget);
    expect(
      find.text('Horizontal — auto-scroll to today, marked dates'),
      findsOneWidget,
    );
    expect(find.text('Nothing picked yet'), findsOneWidget);
  });

  testWidgets('monthly single demo picks a date and marks configured days', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester);
    final now = DateTime.now();

    // The three marked dates (now+4, now+5, now+10) render with their custom
    // decorations as long as they fall inside the displayed month.
    final blue = Colors.blue.withValues(alpha: 0.3);
    const orange = Colors.orange;
    final markedInMonth =
        <DateTime>[
          now.add(const Duration(days: 4)),
          now.add(const Duration(days: 5)),
          now.add(const Duration(days: 10)),
        ].where((d) => _sameMonth(now, d)).toList();

    final markedCells = find.descendant(
      of: _calendar(0),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            [blue, orange].contains((widget.decoration as BoxDecoration).color),
      ),
    );
    expect(markedCells, findsNWidgets(markedInMonth.length));

    await tester.tap(_day(0, '10'));
    await tester.pumpAndSettle();

    final expected = 'Monthly single: [${DateTime(now.year, now.month, 10)}]';
    expect(find.text(expected), findsOneWidget);
  });

  testWidgets('monthly range demo picks a sorted range', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester);
    final now = DateTime.now();

    await tester.tap(_day(1, '15'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Range:'), findsNothing);

    await tester.tap(_day(1, '10'));
    await tester.pumpAndSettle();

    final expected =
        'Range: ${DateTime(now.year, now.month, 10)}'
        ' → ${DateTime(now.year, now.month, 15)}';
    expect(find.text(expected), findsOneWidget);
  });

  testWidgets('weekly demo reports the picked week', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester);

    await tester.tap(
      find
          .descendant(of: _calendar(2), matching: find.textContaining('-'))
          .first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Weekly: ['), findsOneWidget);
  });

  testWidgets('horizontal demo picks a date and reports it', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester);
    final now = DateTime.now();

    await tester.tap(_day(3, '${now.day}'));
    await tester.pumpAndSettle();

    final expected = 'Horizontal: ${DateTime(now.year, now.month, now.day)}';
    expect(find.text(expected), findsOneWidget);
  });

  testWidgets('month/year picker changes the month for a monthly demo', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester);
    final now = DateTime.now();
    final header = DateFormat('MMMM yyyy').format(now);

    await tester.tap(
      find.descendant(of: _calendar(0), matching: find.text(header)),
    );
    await tester.pumpAndSettle();

    // The picker grid only builds the rows in view, so scroll to December.
    await tester.scrollUntilVisible(
      find.text('Dec'),
      120,
      scrollable:
          find
              .descendant(
                of: find.byType(BottomSheet),
                matching: find.byType(Scrollable),
              )
              .first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dec'));
    await tester.pumpAndSettle();

    final newHeader = DateFormat('MMMM yyyy').format(DateTime(now.year, 12));
    expect(
      find.descendant(of: _calendar(0), matching: find.text(newHeader)),
      findsOneWidget,
    );

    await tester.tap(_day(0, '5'));
    await tester.pumpAndSettle();
    final expected = 'Monthly single: [${DateTime(now.year, 12, 5)}]';
    expect(find.text(expected), findsOneWidget);
  });
}

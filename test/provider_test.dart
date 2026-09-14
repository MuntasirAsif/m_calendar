import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:m_calendar/m_calendar.dart';
import 'package:m_calendar/provider/horizontal_calendar_provider.dart';
import 'package:m_calendar/provider/monthly_calender_table_provider.dart';
import 'package:m_calendar/provider/weekly_calendar_table_provider.dart';

void main() {
  group('MonthlyCalendarTableProvider', () {
    test('normalizes the selected month to year/month only', () {
      final provider =
          MonthlyCalendarTableProvider()
            ..initializeMonth(DateTime(2024, 1, 20, 13, 45), null, false);
      expect(provider.selectedMonth, DateTime(2024));
    });

    test('handles leap-year February', () {
      final provider =
          MonthlyCalendarTableProvider()
            ..initializeMonth(DateTime(2024, 2), null, false);
      expect(provider.totalDays, 29);
    });

    test('handles non-leap-year February', () {
      final provider =
          MonthlyCalendarTableProvider()
            ..initializeMonth(DateTime(2025, 2), null, false);
      expect(provider.totalDays, 28);
    });

    test('start offset aligns column 0 with the configured start day', () {
      // Mar 1, 2026 is a Sunday. With a Saturday-first grid the first blank
      // column after column 0 must leave exactly one blank cell (Sun → col 1).
      final saturdayFirst =
          MonthlyCalendarTableProvider()
            ..initializeMonth(DateTime(2026, 3), null, false);
      expect(saturdayFirst.startOffset, 1);
      expect(saturdayFirst.weekNameList.first, 'Sat');

      // Feb 1, 2024 is a Thursday → column 5 of the Saturday-first grid.
      final feb =
          MonthlyCalendarTableProvider()
            ..initializeMonth(DateTime(2024, 2), null, false);
      expect(feb.startOffset, 5);

      // Same months, different week starts.
      final mondayFirst =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2026, 3),
            null,
            false,
            startDay: Day.monday,
          );
      // Mar 1 = Sunday → Monday-first grid column 6.
      expect(mondayFirst.startOffset, 6);
      expect(mondayFirst.weekNameList.first, 'Mon');

      final sundayFirst =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2026, 3),
            null,
            false,
            startDay: Day.sunday,
          );
      // Mar 1 = Sunday → Sunday-first grid column 0.
      expect(sundayFirst.startOffset, 0);
      expect(sundayFirst.weekNameList.first, 'Sun');
    });

    test('weekNameList rotates with every start day', () {
      void check(Day startDay, List<String> expected) {
        final provider =
            MonthlyCalendarTableProvider()..initializeMonth(
              DateTime(2026, 3),
              null,
              false,
              startDay: startDay,
            );
        expect(provider.weekNameList, expected, reason: '$startDay');
      }

      check(Day.monday, ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
      check(Day.wednesday, ['Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue']);
      check(Day.saturday, ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri']);
      check(Day.sunday, ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']);
    });

    test('single selection fires callback with one date', () {
      List<DateTime>? result;
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2024, 5),
            null,
            false,
            onUserPicked: (dates) => result = dates,
          );

      provider.toggleUserPicked(9);

      expect(result, [DateTime(2024, 5, 9)]);
      expect(provider.userPicked, 9);
    });

    test('range selection swaps a reversed range and fires once complete', () {
      final calls = <List<DateTime>>[];
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2024, 5),
            null,
            true,
            onUserPicked: calls.add,
          );

      provider.toggleUserPicked(20);
      expect(calls, isEmpty); // incomplete range → no callback yet
      expect(provider.rangeStart, 20);
      expect(provider.rangeEnd, isNull);

      provider.toggleUserPicked(12);
      expect(calls.single.first, DateTime(2024, 5, 12));
      expect(calls.single.last, DateTime(2024, 5, 20));
      expect(calls.single.length, 9);
    });

    test('same-day range yields a single date', () {
      final calls = <List<DateTime>>[];
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2024, 5),
            null,
            true,
            onUserPicked: calls.add,
          );

      provider.toggleUserPicked(7);
      provider.toggleUserPicked(7);

      expect(calls.single, [DateTime(2024, 5, 7)]);
    });

    test('a third tap after a complete range starts a new range', () {
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2024, 5),
            null,
            true,
            onUserPicked: (_) {},
          );

      provider.toggleUserPicked(1);
      provider.toggleUserPicked(5);
      provider.toggleUserPicked(10);

      expect(provider.rangeStart, 10);
      expect(provider.rangeEnd, isNull);
    });

    test('selectDate normalizes out-of-range dates', () {
      List<DateTime>? picked;
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2024, 2),
            null,
            false,
            onUserPicked: (dates) => picked = dates,
          );

      // February 30 resolves to March 1 via Dart DateTime normalization.
      provider.selectDate(DateTime(2024, 2, 30));

      expect(provider.selectedMonth, DateTime(2024, 3));
      expect(picked, [DateTime(2024, 3)]);
      expect(provider.userPicked, 1);
    });

    test('selectDate switches month and fires the callback', () {
      List<DateTime>? picked;
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2024, 2),
            null,
            false,
            onUserPicked: (dates) => picked = dates,
          );

      provider.selectDate(DateTime(2024, 5, 9, 14, 30));

      expect(provider.selectedMonth, DateTime(2024, 5));
      expect(picked, [DateTime(2024, 5, 9)]);
      expect(provider.userPicked, 9);
    });

    test('selectDate on a disabled date is ignored', () {
      List<DateTime>? picked;
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2026, 3),
            null,
            false,
            minDate: DateTime(2026, 3, 10),
            onUserPicked: (dates) => picked = dates,
          );

      provider.selectDate(DateTime(2026, 3, 5)); // disabled
      expect(picked, isNull);
      expect(provider.userPicked, isNull);

      provider.selectDate(DateTime(2026, 3, 12));
      expect(picked, [DateTime(2026, 3, 12)]);
    });

    test('programmatic same-day range fires with a single date', () {
      List<DateTime>? picked;
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2024, 5),
            null,
            true,
            onUserPicked: (dates) => picked = dates,
          );

      provider.selectRange(DateTime(2024, 5, 9), DateTime(2024, 5, 9));

      expect(picked, [DateTime(2024, 5, 9)]);
      expect(provider.rangeStart, 9);
      expect(provider.rangeEnd, 9);
    });

    test('cross-month selectRange truncates to the end of the start month', () {
      List<DateTime>? picked;
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2024, 3),
            null,
            true,
            onUserPicked: (dates) => picked = dates,
          );

      provider.selectRange(DateTime(2024, 3, 25), DateTime(2024, 4, 5));

      // Highlight runs to Mar 31; the callback reflects the visible range.
      expect(provider.selectedMonth, DateTime(2024, 3));
      expect(provider.rangeStart, 25);
      expect(provider.rangeEnd, 31);
      expect(picked?.length, 7);
      expect(picked!.first, DateTime(2024, 3, 25));
      expect(picked!.last, DateTime(2024, 3, 31));
    });

    test('selectRange normalizes out-of-range dates', () {
      List<DateTime>? picked;
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2024, 2),
            null,
            true,
            onUserPicked: (dates) => picked = dates,
          );

      // Feb 30 → Mar 1 via Dart normalization; range lands on Feb 5..29.
      provider.selectRange(DateTime(2024, 2, 30), DateTime(2024, 2, 5));

      expect(picked, isNotNull);
      expect(picked!.first, DateTime(2024, 2, 5));
      expect(picked!.last, DateTime(2024, 2, 29));
      expect(picked!.length, 25);
      expect(provider.rangeStart, 5);
      expect(provider.rangeEnd, 29);
    });

    test(
      'updateConfiguration refreshes constraints without resetting selection',
      () {
        final provider =
            MonthlyCalendarTableProvider()..initializeMonth(
              DateTime(2026, 3),
              null,
              false,
              onUserPicked: (_) {},
            );

        provider.toggleUserPicked(12);
        expect(provider.userPicked, 12);

        // A new minDate disables day 5 but keeps the existing selection (12).
        var notified = 0;
        provider.addListener(() => notified++);
        provider.updateConfiguration(minDate: DateTime(2026, 3, 10));
        expect(provider.userPicked, 12);
        expect(provider.isDayDisabled(5), isTrue);
        expect(provider.isDayDisabled(10), isFalse);
        expect(notified, 1);

        // Reapplying the same config does not notify listeners.
        provider.updateConfiguration(minDate: DateTime(2026, 3, 10));
        expect(notified, 1);
      },
    );

    test('disabled dates inside a tapped range are surfaced in state', () {
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2026, 3),
            null,
            true,
            isDateDisabled: (date) => date.day == 12,
          );

      provider.toggleUserPicked(10);
      provider.toggleUserPicked(15);

      expect(provider.rangeStart, 10);
      expect(provider.rangeEnd, 15);
      // Range includes the disabled day (10..15); cells repaint it as disabled.
      expect(provider.isInRange(12), isTrue);
      expect(provider.isDayDisabled(12), isTrue);
    });
  });

  group('WeeklyCalendarTableProvider', () {
    test('keeps every day when a month spans six weeks', () {
      // Sep 2023 with a Saturday week start spans 6 weeks.
      final provider =
          WeeklyCalendarTableProvider()
            ..initializeMonth(DateTime(2023, 9), Day.saturday, null, false);

      expect(provider.maxWeekCount, 6);

      final sepWeeks = provider.monthWeekMap['SEP']!;
      final days = sepWeeks.expand((w) => w).toList();
      expect(days.length, 30);
      expect(days.first, DateTime(2023, 9));
      expect(days.last, DateTime(2023, 9, 30));
      // Rows stay aligned: every month has the same number of week cells.
      for (final weeks in provider.monthWeekMap.values) {
        expect(weeks.length, provider.maxWeekCount);
      }
    });

    test('pads short months to 5 weeks', () {
      final provider =
          WeeklyCalendarTableProvider()
            ..initializeMonth(DateTime(2026, 2), Day.saturday, null, false);

      expect(provider.maxWeekCount, greaterThanOrEqualTo(5));
      final febWeeks = provider.monthWeekMap['FEB']!;
      final days = febWeeks.expand((w) => w);
      expect(days.length, 28);
    });

    test('chunks every month into valid weeks for every start day', () {
      final monthsToCheck = [
        DateTime(2024, 2), // leap year February (29 days)
        DateTime(2024, 12), // year transition in the trailing window
        DateTime(2023, 9), // September 2023 spans 6 weeks for Saturday starts
        DateTime(2026, 3),
      ];

      for (final startDay in Day.values) {
        for (final target in monthsToCheck) {
          final provider =
              WeeklyCalendarTableProvider()
                ..initializeMonth(target, startDay, null, false);

          // Every displayed month must chunk each calendar day exactly once
          // and into rows of at most 7 days.
          for (final entry in provider.monthWeekMap.entries) {
            final month = entry.key;
            final weeks = entry.value;
            final days = weeks.expand((w) => w).toList();

            for (final week in weeks) {
              expect(
                week.length,
                lessThanOrEqualTo(7),
                reason: '$startDay $month',
              );
            }

            final unique =
                days.map((d) => '${d.year}-${d.month}-${d.day}').toSet();
            expect(
              unique.length,
              days.length,
              reason: 'no duplicated date for $startDay $month',
            );

            // Days must stay within their own month (weeks never bleed over).
            final monthNumber = provider.monthNameToNumber(month);
            for (final day in days) {
              expect(
                day.month,
                monthNumber,
                reason: '$startDay $month day $day',
              );
            }
          }
        }
      }
    });

    test('Monday-start weeks end on Sunday (regression)', () {
      // Sep 2023, Monday first: the first calendar week is Sep 1-3
      // (Fri, Sat, Sun) because Sundays close the week. Broken code produced a
      // single "1-30" mega-cell for the whole month.
      final provider =
          WeeklyCalendarTableProvider()
            ..initializeMonth(DateTime(2023, 9), Day.monday, null, false);

      final sepWeeks = provider.monthWeekMap['SEP']!;
      final firstWeek = sepWeeks.first;
      expect(firstWeek.first, DateTime(2023, 9));
      expect(firstWeek.last, DateTime(2023, 9, 3));
      expect(firstWeek.length, 3);
    });

    test('weekly range mode currently reports a single date', () {
      List<DateTime>? picked;
      final provider =
          WeeklyCalendarTableProvider()..initializeMonth(
            DateTime(2024, 5),
            Day.monday,
            null,
            true, // isRangeSelection accepted but not implemented yet
            onUserPicked: (dates) => picked = dates,
          );

      provider.toggleUserPicked(DateTime(2024, 5, 3));

      expect(picked, [DateTime(2024, 5, 3)]);
    });

    test('handles year wrap-around for the 5 preceding months', () {
      final provider =
          WeeklyCalendarTableProvider()
            ..initializeMonth(DateTime(2024, 3), Day.monday, null, false);

      expect(provider.monthWeekMap.keys.toList(), [
        'OCT',
        'NOV',
        'DEC',
        'JAN',
        'FEB',
        'MAR',
      ]);
    });

    test('toggleUserPicked reports the picked date', () {
      List<DateTime>? result;
      final provider =
          WeeklyCalendarTableProvider()..initializeMonth(
            DateTime(2024, 5),
            Day.monday,
            null,
            false,
            onUserPicked: (dates) => result = dates,
          );

      provider.toggleUserPicked(DateTime(2024, 5, 3));

      expect(result, [DateTime(2024, 5, 3)]);
      expect(provider.userPicked, DateTime(2024, 5, 3));
    });
  });

  group('HorizontalCalendarProvider', () {
    test('setSelectedMonth normalizes to year/month', () {
      final provider = HorizontalCalendarProvider(onUserPicked: (_) {})
        ..setSelectedMonth(DateTime(2024, 7, 22, 10, 30));
      expect(provider.selectedMonth, DateTime(2024, 7));
    });

    test('daysInMonth covers the whole month', () {
      final provider = HorizontalCalendarProvider(onUserPicked: (_) {})
        ..setSelectedMonth(DateTime(2024, 2));
      final days = provider.daysInMonth;
      expect(days.length, 29); // leap year
      expect(days.first, DateTime(2024, 2));
      expect(days.last, DateTime(2024, 2, 29));
    });

    test('markedModelFor returns the right model among several', () {
      const blue = BoxDecoration(color: Colors.blue);
      const red = BoxDecoration(color: Colors.red);
      final provider = HorizontalCalendarProvider(
        onUserPicked: (_) {},
        markedDaysList: [
          MarkedDaysModel(
            selectedDateList: [DateTime(2024, 3, 3)],
            decoration: blue,
          ),
          MarkedDaysModel(
            selectedDateList: [DateTime(2024, 3, 10)],
            decoration: red,
          ),
        ],
      );

      expect(provider.markedModelFor(DateTime(2024, 3, 10))!.decoration, red);
      expect(provider.markedModelFor(DateTime(2024, 3, 3))!.decoration, blue);
      expect(provider.markedModelFor(DateTime(2024, 3, 5)), isNull);
      expect(provider.isMarked(DateTime(2024, 3, 3)), isTrue);
      expect(provider.isMarked(DateTime(2024, 3, 4)), isFalse);
    });

    test('marked matching ignores the time component', () {
      final provider = HorizontalCalendarProvider(
        onUserPicked: (_) {},
        markedDaysList: [
          MarkedDaysModel(
            selectedDateList: [DateTime(2024, 3, 3, 23, 59)],
            decoration: const BoxDecoration(),
          ),
        ],
      );

      expect(provider.isMarked(DateTime(2024, 3, 3)), isTrue);
    });

    test('setSelectedDay triggers the callback', () {
      DateTime? picked;
      final provider = HorizontalCalendarProvider(
        onUserPicked: (d) => picked = d,
      );

      provider.setSelectedDay(DateTime(2024, 6, 15));

      expect(picked, DateTime(2024, 6, 15));
      expect(provider.selectedDay, DateTime(2024, 6, 15));
    });
  });

  group('MonthlyCalendarTableProvider disabled dates', () {
    test('dates before minDate are disabled and cannot be picked', () {
      List<DateTime>? picked;
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2026, 3),
            null,
            false,
            minDate: DateTime(2026, 3, 10),
            onUserPicked: (d) => picked = d,
          );

      expect(provider.isDayDisabled(5), isTrue);
      expect(provider.isDayDisabled(10), isFalse);
      expect(provider.isDayDisabled(15), isFalse);

      provider.toggleUserPicked(5);
      expect(picked, isNull);
      expect(provider.userPicked, isNull);

      provider.toggleUserPicked(12);
      expect(picked, isNotNull);
      expect(provider.userPicked, 12);
    });

    test('dates after maxDate are disabled and cannot be picked', () {
      List<DateTime>? picked;
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2026, 3),
            null,
            false,
            maxDate: DateTime(2026, 3, 20),
            onUserPicked: (d) => picked = d,
          );

      expect(provider.isDayDisabled(20), isFalse);
      expect(provider.isDayDisabled(25), isTrue);

      provider.toggleUserPicked(25);
      expect(picked, isNull);
      expect(provider.userPicked, isNull);

      provider.toggleUserPicked(15);
      expect(picked, isNotNull);
      expect(provider.userPicked, 15);
    });

    test('isDateDisabled predicate disables specific dates', () {
      List<DateTime>? picked;
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2026, 3),
            null,
            false,
            isDateDisabled: (date) => date.weekday == DateTime.sunday,
            onUserPicked: (d) => picked = d,
          );

      // March 1, 2026 is Sunday
      expect(provider.isDayDisabled(1), isTrue);
      // March 2, 2026 is Monday
      expect(provider.isDayDisabled(2), isFalse);

      provider.toggleUserPicked(1);
      expect(picked, isNull);

      provider.toggleUserPicked(2);
      expect(picked, isNotNull);
    });
  });

  group('MCalendarController', () {
    test('initializes with default or custom month', () {
      final controller = MCalendarController(initialMonth: DateTime(2025, 6));
      expect(controller.displayedMonth, DateTime(2025, 6));
    });

    test('navigates nextMonth and previousMonth', () {
      final controller = MCalendarController(initialMonth: DateTime(2025, 12));
      controller.nextMonth();
      expect(controller.displayedMonth, DateTime(2026));

      controller.previousMonth();
      expect(controller.displayedMonth, DateTime(2025, 12));
    });

    test('drives attached provider and queries selection', () {
      List<DateTime>? picked;
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2026, 3),
            null,
            false,
            onUserPicked: (d) => picked = d,
          );
      final controller = MCalendarController();
      controller.attach(provider);

      expect(controller.displayedMonth, DateTime(2026, 3));
      expect(controller.selectedDates, isEmpty);

      controller.selectDate(DateTime(2026, 3, 14));
      expect(picked, [DateTime(2026, 3, 14)]);
      expect(controller.selectedDates, [DateTime(2026, 3, 14)]);

      controller.clearSelection();
      expect(controller.selectedDates, isEmpty);

      controller.detach();
    });

    test('selectRange selects full range via attached provider', () {
      List<DateTime>? picked;
      final provider =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2026, 3),
            null,
            true,
            onUserPicked: (d) => picked = d,
          );
      final controller = MCalendarController();
      controller.attach(provider);

      controller.selectRange(DateTime(2026, 3, 10), DateTime(2026, 3, 13));
      expect(picked?.length, 4);
      expect(controller.selectedDates.length, 4);
      expect(controller.selectedDates.first, DateTime(2026, 3, 10));
      expect(controller.selectedDates.last, DateTime(2026, 3, 13));
    });
  });

  group('Backward-compatible aliases', () {
    test('deprecated misspelled aliases still resolve', () {
      // ignore: deprecated_member_use_from_same_package
      final MonthlyCalenderTableProvider monthly =
          MonthlyCalendarTableProvider();
      // ignore: deprecated_member_use_from_same_package
      final WeeklyCalenderTableProvider weekly = WeeklyCalendarTableProvider();
      expect(monthly, isA<MonthlyCalendarTableProvider>());
      expect(weekly, isA<WeeklyCalendarTableProvider>());
    });
  });
}

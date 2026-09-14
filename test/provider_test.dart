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

    test('computes start offset (weekday % 7)', () {
      // Feb 1, 2024 is a Thursday (weekday == 4).
      final provider =
          MonthlyCalendarTableProvider()
            ..initializeMonth(DateTime(2024, 2), null, false);
      expect(provider.startOffset, 4);
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

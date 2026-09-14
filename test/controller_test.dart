import 'package:flutter_test/flutter_test.dart';
import 'package:m_calendar/m_calendar.dart';
import 'package:m_calendar/provider/horizontal_calendar_provider.dart';
import 'package:m_calendar/provider/monthly_calender_table_provider.dart';
import 'package:m_calendar/provider/weekly_calendar_table_provider.dart';

void main() {
  group('MCalendarController detached', () {
    test('fallback displayed month', () {
      final controller = MCalendarController(
        initialMonth: DateTime(2026, 3, 7),
      );
      expect(controller.displayedMonth, DateTime(2026, 3));
      controller.dispose();
    });

    test('setMonth normalizes and notifies', () {
      final controller = MCalendarController(initialMonth: DateTime(2026, 3));
      var notified = 0;
      controller.addListener(() => notified++);

      controller.setMonth(DateTime(2026, 11, 28, 14, 30));
      expect(controller.displayedMonth, DateTime(2026, 11));
      expect(notified, 1);

      controller.setMonth(DateTime(2026, 11));
      expect(notified, 2, reason: 'always notifies');

      controller.dispose();
    });

    test('nextMonth and previousMonth wrap year boundaries', () {
      final controller = MCalendarController(initialMonth: DateTime(2026, 12));
      controller.nextMonth();
      expect(controller.displayedMonth, DateTime(2027));

      controller.previousMonth();
      controller.previousMonth();
      expect(controller.displayedMonth, DateTime(2026, 11));
      controller.dispose();
    });

    test('selectedDates is empty while detached', () {
      final controller = MCalendarController();
      expect(controller.selectedDates, isEmpty);
      controller.dispose();
    });
  });

  group('MCalendarController monthly', () {
    test('displayedMonth follows the provider and fallback stays in sync', () {
      final controller = MCalendarController(initialMonth: DateTime(2026, 3));
      final monthly =
          MonthlyCalendarTableProvider()
            ..initializeMonth(DateTime(2026, 3), null, false);

      controller.attach(monthly);
      expect(controller.displayedMonth, DateTime(2026, 3));

      // Navigate through the provider directly.
      monthly.setMonth(DateTime(2026, 7));
      expect(controller.displayedMonth, DateTime(2026, 7));

      // Detach: the fallback must retain the last provider month.
      controller.detach();
      expect(controller.displayedMonth, DateTime(2026, 7));
      controller.dispose();
    });

    test('provider changes notify controller listeners', () {
      final controller = MCalendarController();
      final monthly =
          MonthlyCalendarTableProvider()
            ..initializeMonth(DateTime(2026, 3), null, false);
      controller.attach(monthly);

      var notified = 0;
      controller.addListener(() => notified++);
      monthly.toggleUserPicked(5);

      expect(notified, 1);
      expect(controller.selectedDates, [DateTime(2026, 3, 5)]);
      controller.dispose();
    });

    test('detach stops forwarding provider notifications', () {
      final controller = MCalendarController();
      final monthly =
          MonthlyCalendarTableProvider()
            ..initializeMonth(DateTime(2026, 3), null, false);
      controller.attach(monthly);
      controller.detach();

      var notified = 0;
      controller.addListener(() => notified++);
      monthly.toggleUserPicked(5);

      expect(notified, 0);
      expect(controller.selectedDates, isEmpty);
      controller.dispose();
    });

    test('setMonth drives the attached provider', () {
      final controller = MCalendarController(initialMonth: DateTime(2026, 3));
      final monthly =
          MonthlyCalendarTableProvider()
            ..initializeMonth(DateTime(2026, 3), null, false);
      controller.attach(monthly);

      controller.setMonth(DateTime(2026, 10));
      expect(monthly.selectedMonth, DateTime(2026, 10));
      expect(controller.displayedMonth, DateTime(2026, 10));
      controller.dispose();
    });

    test('selectDate fans out to the monthly provider and callback', () {
      List<DateTime>? picked;
      final controller = MCalendarController();
      final monthly =
          MonthlyCalendarTableProvider()..initializeMonth(
            DateTime(2026, 3),
            null,
            false,
            onUserPicked: (dates) => picked = dates,
          );
      controller.attach(monthly);

      controller.selectDate(DateTime(2026, 5, 2));

      expect(monthly.selectedMonth, DateTime(2026, 5));
      expect(controller.selectedDates, [DateTime(2026, 5, 2)]);
      expect(picked, [DateTime(2026, 5, 2)]);
      controller.dispose();
    });

    test('selectRange and clearSelection update the monthly provider', () {
      final controller = MCalendarController();
      final monthly =
          MonthlyCalendarTableProvider()
            ..initializeMonth(DateTime(2026, 5), null, true);
      controller.attach(monthly);

      controller.selectRange(DateTime(2026, 5, 4), DateTime(2026, 5, 8));
      expect(monthly.rangeStart, 4);
      expect(monthly.rangeEnd, 8);
      expect(controller.selectedDates.length, 5);

      controller.clearSelection();
      expect(monthly.rangeStart, isNull);
      expect(monthly.rangeEnd, isNull);
      expect(controller.selectedDates, isEmpty);
      controller.dispose();
    });

    test('re-attaching replaces the provider cleanly', () {
      final controller = MCalendarController(initialMonth: DateTime(2026, 3));
      final first =
          MonthlyCalendarTableProvider()
            ..initializeMonth(DateTime(2026, 3), null, false);
      final second =
          MonthlyCalendarTableProvider()
            ..initializeMonth(DateTime(2026, 3), null, false);
      controller.attach(first);
      controller.attach(second);

      // Provider replaced: change the old one, controller must stay silent.
      var notified = 0;
      controller.addListener(() => notified++);
      first.toggleUserPicked(9);
      expect(notified, 0);
      controller.dispose();
    });
  });

  group('MCalendarController weekly + horizontal', () {
    test('weekly selection is reflected via selectedDates', () {
      final controller = MCalendarController(initialMonth: DateTime(2026, 3));
      final weekly =
          WeeklyCalendarTableProvider()
            ..initializeMonth(DateTime(2026, 3), Day.saturday, null, false);
      controller.attach(weekly);

      controller.selectDate(DateTime(2026, 3, 15));
      expect(controller.selectedDates, [DateTime(2026, 3, 15)]);
      expect(weekly.userPicked, DateTime(2026, 3, 15));

      // setMonth drives the weekly provider too.
      controller.setMonth(DateTime(2026, 8));
      expect(weekly.selectedMonth, DateTime(2026, 8));
      controller.dispose();
    });

    test('horizontal provider is driven and reported', () {
      final controller = MCalendarController(initialMonth: DateTime(2026, 3));
      final horizontal = HorizontalCalendarProvider(onUserPicked: (_) {});
      controller.attach(horizontal);

      controller.selectDate(DateTime(2026, 3, 12));
      expect(horizontal.selectedDay, DateTime(2026, 3, 12));
      expect(controller.selectedDates, [DateTime(2026, 3, 12)]);

      controller.setMonth(DateTime(2026, 4));
      expect(horizontal.selectedMonth, DateTime(2026, 4));
      controller.dispose();
    });

    test('clearSelection clears horizontal and weekly providers too', () {
      final controller = MCalendarController(initialMonth: DateTime(2026, 3));
      final monthly =
          MonthlyCalendarTableProvider()
            ..initializeMonth(DateTime(2026, 3), null, false);
      final weekly =
          WeeklyCalendarTableProvider()
            ..initializeMonth(DateTime(2026, 3), Day.saturday, null, false);
      final horizontal = HorizontalCalendarProvider(onUserPicked: (_) {});
      controller
        ..attach(monthly)
        ..attach(weekly)
        ..attach(horizontal);

      controller.selectDate(DateTime(2026, 3, 12));
      expect(weekly.userPicked, DateTime(2026, 3, 12));
      expect(horizontal.selectedDay, DateTime(2026, 3, 12));

      controller.clearSelection();
      expect(monthly.userPicked, isNull);
      expect(weekly.userPicked, isNull);
      expect(horizontal.selectedDay.year, 0);
      controller.dispose();
    });
  });
}

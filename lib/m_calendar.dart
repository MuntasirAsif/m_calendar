import 'package:flutter/material.dart';
import 'package:m_calendar/provider/horizontal_calendar_provider.dart';
import 'package:m_calendar/provider/monthly_calender_table_provider.dart';
import 'package:m_calendar/provider/weekly_calendar_table_provider.dart';
import 'package:m_calendar/view/horizontal_view.dart';
import 'package:m_calendar/view/monthly_view.dart';
import 'package:m_calendar/view/weekly_view.dart';
import 'package:provider/provider.dart';

import 'controller/m_calendar_controller.dart';
import 'model/day_state.dart';
import 'model/marked_date_model.dart';

export 'controller/m_calendar_controller.dart' show MCalendarController;
export 'model/day_state.dart' show CalendarDayBuilder, DayState;
export 'model/marked_date_model.dart' show MarkedDaysModel;
export 'provider/weekly_calendar_table_provider.dart' show Day;

/// A flexible calendar widget with monthly, weekly, and horizontal layouts.
///
/// Use the unnamed [MCalendar] constructor (or [MCalendar.monthly]) for a
/// classic month grid, [MCalendar.weekly] for a month organized into labeled
/// weeks, and [MCalendar.horizontal] for a horizontally scrolling strip of
/// the days of a month.
///
/// ```dart
/// MCalendar(
///   selectedMonth: DateTime.now(),
///   onUserPicked: (dates) => debugPrint('$dates'),
/// )
/// ```
///
/// ## Selection callbacks
///
/// `MCalendar`, [MCalendar.monthly] and [MCalendar.weekly] report selections
/// as `void Function(List<DateTime>)`: a single-element list for single
/// selection, or every date in the range when `isRangeSelection` is `true`
/// (fired once both range ends are picked).
///
/// [MCalendar.horizontal] always reports a single `DateTime` via
/// `void Function(DateTime)` because it only supports single-date selection.
class MCalendar extends StatelessWidget {
  /// Default constructor → redirects to monthly view.
  ///
  /// This constructor delegates the creation of the calendar to the `MCalendar.monthly` constructor.
  factory MCalendar({
    required DateTime selectedMonth,
    BoxDecoration? decoration,
    List<MarkedDaysModel>? markedDaysList,
    TextStyle? weekNameHeaderStyle,
    Widget? defaultChild,
    bool isRangeSelection = false,
    bool showMonthYearPicker = false,
    BoxDecoration? userPickedDecoration,
    Widget? userPickedChild,
    EdgeInsets? cellPadding,
    required void Function(List<DateTime>) onUserPicked,
    MCalendarController? controller,
    CalendarDayBuilder? dayBuilder,
    DateTime? minDate,
    DateTime? maxDate,
    bool Function(DateTime date)? isDateDisabled,
    BoxDecoration? disabledDecoration,
    TextStyle? disabledTextStyle,
  }) => MCalendar.monthly(
    selectedMonth: selectedMonth,
    decoration: decoration,
    markedDaysList: markedDaysList,
    weekNameHeaderStyle: weekNameHeaderStyle,
    defaultChild: defaultChild,
    isRangeSelection: isRangeSelection,
    userPickedDecoration: userPickedDecoration,
    userPickedChild: userPickedChild,
    cellPadding: cellPadding,
    onUserPicked: onUserPicked,
    showMonthYearPicker: showMonthYearPicker,
    controller: controller,
    dayBuilder: dayBuilder,
    minDate: minDate,
    maxDate: maxDate,
    isDateDisabled: isDateDisabled,
    disabledDecoration: disabledDecoration,
    disabledTextStyle: disabledTextStyle,
  );

  const MCalendar._({required this.child});

  /// Factory constructor for the monthly view of the calendar.
  ///
  /// This method initializes the `MonthlyCalendarTableProvider` and provides the month view layout.
  /// It includes various customization options for decoration, user-picked dates, range selection,
  /// date disabling, custom day builders, and programmatic control.
  ///
  /// Parameters:
  /// - `selectedMonth`: The currently selected month (required).
  /// - `decoration`: The decoration applied to the calendar container (optional).
  /// - `markedDaysList`: A list of marked days to highlight in the calendar (optional).
  /// - `weekNameHeaderStyle`: The style applied to the week name header (optional).
  /// - `defaultChild`: The default child widget to display (optional).
  /// - `isRangeSelection`: Flag indicating whether range selection is enabled (default is `false`).
  /// - `showMonthYearPicker`: Whether to show month/year picker in header (default is `true`).
  /// - `userPickedDecoration`: The decoration for selected user-picked dates (optional).
  /// - `userPickedChild`: The widget to display for selected user-picked dates (optional).
  /// - `cellPadding`: The padding for each calendar cell (optional).
  /// - `onUserPicked`: Callback triggered when the user picks a date (required).
  /// - `controller`: Optional controller to programmatically manipulate the calendar.
  /// - `dayBuilder`: Optional builder to customize rendering of individual day cells.
  /// - `minDate`: Earliest selectable date.
  /// - `maxDate`: Latest selectable date.
  /// - `isDateDisabled`: Optional predicate to disable specific dates.
  /// - `disabledDecoration`: Decoration for disabled day cells.
  /// - `disabledTextStyle`: Text style for disabled day cell numbers.
  ///
  /// Returns an `MCalendar` widget with the monthly view.
  factory MCalendar.monthly({
    required DateTime selectedMonth,
    BoxDecoration? decoration,
    List<MarkedDaysModel>? markedDaysList,
    TextStyle? weekNameHeaderStyle,
    Widget? defaultChild,
    bool isRangeSelection = false,
    bool showMonthYearPicker = true,
    BoxDecoration? userPickedDecoration,
    Widget? userPickedChild,
    EdgeInsets? cellPadding,
    required void Function(List<DateTime>) onUserPicked,
    MCalendarController? controller,
    CalendarDayBuilder? dayBuilder,
    DateTime? minDate,
    DateTime? maxDate,
    bool Function(DateTime date)? isDateDisabled,
    BoxDecoration? disabledDecoration,
    TextStyle? disabledTextStyle,
  }) {
    final effectiveMonth = controller?.initialMonth ?? selectedMonth;
    return MCalendar._(
      child: ChangeNotifierProvider(
        create:
            (_) =>
                MonthlyCalendarTableProvider()..initializeMonth(
                  effectiveMonth,
                  markedDaysList,
                  isRangeSelection,
                  onUserPicked: onUserPicked,
                  minDate: minDate,
                  maxDate: maxDate,
                  isDateDisabled: isDateDisabled,
                ),
        child: MonthlyView(
          selectedMonth: effectiveMonth,
          decoration: decoration,
          markedDaysList: markedDaysList,
          weekNameHeaderStyle: weekNameHeaderStyle,
          defaultChild: defaultChild,
          userPickedDecoration: userPickedDecoration,
          userPickedChild: userPickedChild,
          cellPadding: cellPadding,
          onUserPicked: onUserPicked,
          showMonthYearPicker: showMonthYearPicker,
          controller: controller,
          dayBuilder: dayBuilder,
          minDate: minDate,
          maxDate: maxDate,
          isDateDisabled: isDateDisabled,
          disabledDecoration: disabledDecoration,
          disabledTextStyle: disabledTextStyle,
        ),
      ),
    );
  }

  /// Factory constructor for the weekly view of the calendar.
  ///
  /// This method initializes the `WeeklyCalendarTableProvider` and provides the week view layout.
  /// It includes various customization options for decoration, user-picked dates, and range selection.
  ///
  /// Parameters:
  /// - `selectedMonth`: The currently selected month (required).
  /// - `decoration`: The decoration applied to the calendar container (optional).
  /// - `markedDaysList`: A list of marked days to highlight in the calendar (optional).
  /// - `weekNameHeaderStyle`: The style applied to the week name header (optional).
  /// - `defaultChild`: The default child widget to display (optional).
  /// - `isRangeSelection`: Flag indicating whether range selection is enabled (default is `false`).
  /// - `userPickedDecoration`: The decoration for selected user-picked dates (optional).
  /// - `userPickedChild`: The widget to display for selected user-picked dates (optional).
  /// - `cellPadding`: The padding for each calendar cell (optional).
  /// - `startDay`: The starting day of the week (default is Saturday).
  /// - `onUserPicked`: Callback triggered when the user picks a date (required).
  ///
  /// Returns an `MCalendar` widget with the weekly view.
  factory MCalendar.weekly({
    required DateTime selectedMonth,
    BoxDecoration? decoration,
    List<MarkedDaysModel>? markedDaysList,
    TextStyle? weekNameHeaderStyle,
    Widget? defaultChild,
    bool isRangeSelection = false,
    BoxDecoration? userPickedDecoration,
    Widget? userPickedChild,
    EdgeInsets? cellPadding,
    Day startDay = Day.saturday,
    required void Function(List<DateTime>) onUserPicked,
  }) {
    return MCalendar._(
      child: ChangeNotifierProvider(
        create:
            (_) =>
                WeeklyCalendarTableProvider()..initializeMonth(
                  selectedMonth,
                  startDay,
                  markedDaysList,
                  isRangeSelection,
                  onUserPicked: onUserPicked,
                ),
        child: WeeklyView(
          selectedMonth: selectedMonth,
          markedDaysList: markedDaysList,
          weekNameHeaderStyle: weekNameHeaderStyle,
          userPickedDecoration: userPickedDecoration,
          userPickedChild: userPickedChild,
          cellPadding: cellPadding,
          onUserPicked: onUserPicked,
          decoration: decoration,
          defaultChild: defaultChild,
          isRangeSelection: isRangeSelection,
          startDay: startDay,
        ),
      ),
    );
  }

  /// Factory constructor for the horizontal view of the calendar.
  ///
  factory MCalendar.horizontal({
    required DateTime selectedMonth,
    BoxDecoration? decoration,
    List<MarkedDaysModel>? markedDaysList,
    Widget? defaultChild,
    bool showMonthYearPicker = false,
    BoxDecoration? userPickedDecoration,
    Widget? userPickedChild,
    required void Function(DateTime) onUserPicked,
    double? headerHeight,
    Color? headerIconColor,
    TextStyle? headerTextStyle,
    Color? monthYearPickerSelectedMonthColor,
    Color? monthYearPickerUnselectedMonthColor,
    int? monthYearPickerCrossAxisCount,
    double? monthYearPickerChildAspectRatio,
    BoxDecoration? monthYearPickerMonthItemDecoration,
    bool showWeekDays = true,
    TextStyle? dateTextStyle,
    TextStyle? weekDaysTextStyle,
    TextStyle? selectedDateTextStyle,
    TextStyle? selectedWeekDaysTextStyle,
    DateTime? initialDate,
    DateTime? endDate,
    bool autoScroll = true,
  }) {
    assert(
      initialDate == null ||
          endDate == null ||
          !_dateOnly(initialDate).isAfter(_dateOnly(endDate)),
      'MCalendar.horizontal: `initialDate` must not be after `endDate`.',
    );
    return MCalendar._(
      child: ChangeNotifierProvider(
        create:
            (context) => HorizontalCalendarProvider(
              markedDaysList: markedDaysList,
              onUserPicked: onUserPicked,
            )..setSelectedMonth(selectedMonth),
        child: HorizontalView(
          decoration: decoration,
          defaultChild: defaultChild,
          userPickedDecoration: userPickedDecoration,
          userPickedChild: userPickedChild,
          showMonthYearPicker: showMonthYearPicker,
          headerHeight: headerHeight,
          headerIconColor: headerIconColor,
          headerTextStyle: headerTextStyle,
          monthYearPickerSelectedMonthColor: monthYearPickerSelectedMonthColor,
          monthYearPickerUnselectedMonthColor:
              monthYearPickerUnselectedMonthColor,
          monthYearPickerCrossAxisCount: monthYearPickerCrossAxisCount,
          monthYearPickerChildAspectRatio: monthYearPickerChildAspectRatio,
          monthYearPickerMonthItemDecoration:
              monthYearPickerMonthItemDecoration,
          showWeekDays: showWeekDays,
          dateTextStyle: dateTextStyle,
          weekDaysTextStyle: weekDaysTextStyle,
          selectedDateTextStyle: selectedDateTextStyle,
          selectedWeekDaysTextStyle: selectedWeekDaysTextStyle,
          initialDate: initialDate,
          endDate: endDate,
          autoScroll: autoScroll,
        ),
      ),
    );
  }

  /// The child widget displayed by the `MCalendar` widget.
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Returns a date-only copy of [date] (time components removed).
DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

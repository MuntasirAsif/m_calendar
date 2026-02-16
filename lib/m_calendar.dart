import 'package:flutter/material.dart';
import 'package:m_calendar/provider/horizontal_calendar_provider.dart';
import 'package:m_calendar/provider/monthly_calender_table_provider.dart';
import 'package:m_calendar/provider/weekly_calendar_table_provider.dart';
import 'package:m_calendar/view/horizontal_view.dart';
import 'package:m_calendar/view/monthly_view.dart';
import 'package:m_calendar/view/weekly_view.dart';
import 'package:provider/provider.dart';

import 'model/marked_date_model.dart';

/// A flexible calendar widget that provides both monthly and weekly views.
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
  );

  const MCalendar._({required this.child});

  /// Factory constructor for the monthly view of the calendar.
  ///
  /// This method initializes the `MonthlyCalenderTableProvider` and provides the month view layout.
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
  /// - `onUserPicked`: Callback triggered when the user picks a date (required).
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
  }) {
    return MCalendar._(
      child: ChangeNotifierProvider(
        create:
            (_) =>
                MonthlyCalenderTableProvider()..initializeMonth(
                  selectedMonth,
                  markedDaysList,
                  isRangeSelection,
                  onUserPicked: onUserPicked,
                ),
        child: MonthlyView(
          selectedMonth: selectedMonth,
          decoration: decoration,
          markedDaysList: markedDaysList,
          weekNameHeaderStyle: weekNameHeaderStyle,
          defaultChild: defaultChild,
          userPickedDecoration: userPickedDecoration,
          userPickedChild: userPickedChild,
          cellPadding: cellPadding,
          onUserPicked: onUserPicked,
          showMonthYearPicker: showMonthYearPicker,
        ),
      ),
    );
  }

  /// Factory constructor for the weekly view of the calendar.
  ///
  /// This method initializes the `WeeklyCalenderTableProvider` and provides the week view layout.
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
                WeeklyCalenderTableProvider()..initializeMonth(
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

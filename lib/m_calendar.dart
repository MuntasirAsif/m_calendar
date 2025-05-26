import 'package:flutter/material.dart';
import 'package:m_calendar/provider/monthly_calender_table_provider.dart';
import 'package:m_calendar/provider/weekly_calendar_table_provider.dart';
import 'package:m_calendar/view/monthly_view.dart';
import 'package:m_calendar/view/weekly_view.dart';
import 'package:provider/provider.dart';

import 'model/marked_date_model.dart';

class MCalendar extends StatelessWidget {

  /// Default constructor → redirects to monthly
  factory MCalendar({
    required DateTime selectedMonth,
    BoxDecoration? decoration,
    List<MarkedDaysModel>? markedDaysList,
    TextStyle? weekNameHeaderStyle,
    Widget? defaultChild,
    bool isRangeSelection = false,
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
  );

  const MCalendar._({required this.child, super.key});

  /// Monthly view
  factory MCalendar.monthly({
    required DateTime selectedMonth,
    BoxDecoration? decoration,
    List<MarkedDaysModel>? markedDaysList,
    TextStyle? weekNameHeaderStyle,
    Widget? defaultChild,
    bool isRangeSelection = false,
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
                  selectedMonth ?? DateTime.now(),
                  markedDaysList,
                  isRangeSelection,
                  onUserPicked: onUserPicked,
                ),
        child: MonthlyView(
          selectedMonth: selectedMonth ?? DateTime.now(),
          decoration: decoration,
          markedDaysList: markedDaysList,
          weekNameHeaderStyle: weekNameHeaderStyle,
          defaultChild: defaultChild,
          userPickedDecoration: userPickedDecoration,
          userPickedChild: userPickedChild,
          cellPadding: cellPadding,
          onUserPicked: onUserPicked,
        ),
      ),
    );
  }

  /// Weekly view
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
    required void Function(List<DateTime>) onUserPicked,
  }) {
    return MCalendar._(
      child: ChangeNotifierProvider(
        create:
            (_) =>
                WeeklyCalenderTableProvider()..initializeMonth(
                  selectedMonth,
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
        ),
      ),
    );
  }


  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

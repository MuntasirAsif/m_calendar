import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/monthly_calender_table_provider.dart';
import '../widgets/calendar_date_cell.dart';
import '../model/marked_date_model.dart';

/// A widget that displays the monthly calendar view, showing the days of a month
/// and allowing the user to select dates.
///
/// This widget allows the user to interact with the calendar, selecting individual
/// dates and providing a callback when dates are selected.
class MonthlyView extends StatelessWidget {
  /// Constructs a `MonthlyView` widget.
  const MonthlyView({
    super.key,
    required this.selectedMonth,
    this.decoration,
    this.markedDaysList,
    this.weekNameHeaderStyle,
    this.defaultChild,
    this.userPickedDecoration,
    this.userPickedChild,
    this.cellPadding,
    required this.onUserPicked,
  });

  /// The currently selected month for the calendar.
  ///
  /// This DateTime object represents the month that will be displayed in the calendar.
  final DateTime selectedMonth;

  /// The decoration applied to the calendar container.
  ///
  /// This is an optional `BoxDecoration` used to decorate the entire calendar container.
  final BoxDecoration? decoration;

  /// A list of custom marked days to highlight in the calendar.
  ///
  /// This is an optional list of `MarkedDaysModel` that indicates specific days
  /// to be highlighted in the calendar, such as holidays or special events.
  final List<MarkedDaysModel>? markedDaysList;

  /// The style applied to the week name header (e.g., "Mon", "Tue", "Wed", etc.).
  ///
  /// This optional `TextStyle` is used to customize the appearance of the week header row.
  final TextStyle? weekNameHeaderStyle;

  /// The default widget to display inside each calendar date cell.
  ///
  /// This widget will be displayed inside each date cell if no custom content is provided.
  final Widget? defaultChild;

  /// The decoration applied to user-selected dates.
  ///
  /// This `BoxDecoration` is used to highlight the selected dates in the calendar.
  final BoxDecoration? userPickedDecoration;

  /// The widget displayed inside the cells of the user-selected dates.
  ///
  /// This widget is displayed inside the date cells that represent user-selected dates.
  final Widget? userPickedChild;

  /// The padding around each calendar cell.
  ///
  /// This defines the padding applied to each individual date cell in the calendar.
  final EdgeInsets? cellPadding;

  /// A callback triggered when the user selects a date or a range of dates.
  ///
  /// This callback provides a list of `DateTime` objects representing the selected dates.
  final void Function(List<DateTime>) onUserPicked;

  @override
  Widget build(BuildContext context) {
    return Consumer<MonthlyCalenderTableProvider>(
      builder: (_, provider, __) {
        return Column(
          children: [
            Table(
              children: [
                // Week header row (e.g., "Mon", "Tue", "Wed", etc.)
                TableRow(
                  children:
                      provider.weekNameList.map((name) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              name,
                              style:
                                  weekNameHeaderStyle ??
                                  const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                // Rows representing the days of the month
                ..._generateCalendarRows(provider),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Generates rows for the calendar, breaking the days of the month into weeks.
  ///
  /// This method creates the cells for each day in the month, filling the calendar
  /// grid by first adding empty spaces before the first day and then adding the
  /// date cells. The rows are then broken into 7-day groups (weeks).
  List<TableRow> _generateCalendarRows(MonthlyCalenderTableProvider provider) {
    final List<Widget> dayCells = [];

    // Fill empty days before the first of the month
    for (int i = 0; i < provider.startOffset; i++) {
      dayCells.add(const SizedBox.shrink());
    }

    // Add date cells for each day of the month
    for (int i = 1; i <= provider.totalDays; i++) {
      dayCells.add(
        CalendarDateCell(
          i: i,
          defaultDecoration: decoration,
          defaultChild: defaultChild,
          userPickedDecoration: userPickedDecoration,
          userPickedChild: userPickedChild,
          cellPadding: cellPadding,
        ),
      );
    }

    // Fill empty cells after the last day of the month
    while (dayCells.length % 7 != 0) {
      dayCells.add(const SizedBox.shrink());
    }

    // Break the cells into weeks (7 cells per week)
    final List<TableRow> rows = [];
    for (int i = 0; i < dayCells.length; i += 7) {
      rows.add(TableRow(children: dayCells.sublist(i, i + 7)));
    }

    return rows;
  }
}

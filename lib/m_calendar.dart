import 'package:flutter/material.dart';
import 'package:m_calendar/provider/calender_table_provider.dart';
import 'package:m_calendar/widgets/calendar_date_cell.dart';
import 'package:provider/provider.dart';

import 'model/marked_date_model.dart';

/// A customizable Flutter calendar widget that displays days of a selected month
/// and supports both single and range-based date selection.
///
/// The calendar provides flexibility through decoration, styling, and custom
/// day cell content. It uses a [ChangeNotifierProvider] to manage calendar state.
class MCalendar extends StatelessWidget {
  /// Creates an [MCalendar] widget with optional styling and configuration.
  const MCalendar({
    super.key,
    this.selectedMonth,
    this.decoration,
    this.markedDaysList,
    this.weekNameHeaderStyle,
    this.defaultChild,
    this.isRangeSelection,
    this.userPickedDecoration,
    this.userPickedChild,
  });

  /// Specifies the initially selected month displayed in the calendar.
  final DateTime? selectedMonth;

  /// Defines the default decoration applied to each calendar day cell.
  final BoxDecoration? decoration;

  /// Contains the list of days that are marked as selected in the calendar.
  final List<MarkedDaysModel>? markedDaysList;

  /// Applies styling to the weekday header names (e.g., Mon, Tue).
  final TextStyle? weekNameHeaderStyle;

  /// The default widget displayed in a date cell when no specific selection or state is applied.
  final Widget? defaultChild;

  /// Determines whether the calendar uses range-based date selection.
  final bool? isRangeSelection;

  /// The box decoration for userPicked date design
  final BoxDecoration? userPickedDecoration;

  /// A custom widget to display when the user selects this cell.
  final Widget? userPickedChild;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) =>
              CalenderTableProvider()..initializeMonth(
                selectedMonth ?? DateTime.now(),
                markedDaysList,
                isRangeSelection ?? false,
              ),
      child: StreamBuilder<Object>(
        stream: null,
        builder: (context, snapshot) {
          return Consumer<CalenderTableProvider>(
            builder: (_, provider, __) {
              return Column(
                children: [
                  /// Render weekday headers (e.g., Sat, Sun, Mon, ...)
                  Table(
                    children: [
                      TableRow(
                        children:
                            provider.weekNameList.map((name) {
                              return Center(
                                child: Text(
                                  name,
                                  style:
                                      weekNameHeaderStyle ??
                                      const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              );
                            }).toList(),
                      ),

                      /// Render calendar day cells in weekly rows
                      ...generateCalendarRows(
                        provider: provider,
                        decoration: decoration,
                        defaultChild: defaultChild,
                        userPickedDecoration: userPickedDecoration,
                        userPickedChild: userPickedChild
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Generates a list of [TableRow]s to display calendar days, organized by week.
  ///
  /// Adds leading empty cells for the first week's offset and fills trailing cells
  /// to ensure each row has exactly 7 columns.
  ///
  /// Returns a list of [TableRow] widgets to be rendered in a [Table].
  List<TableRow> generateCalendarRows({
    Widget? defaultChild,
    Widget? userPickedChild,
    BoxDecoration? decoration,
    BoxDecoration? userPickedDecoration,
    required CalenderTableProvider provider,
  }) {
    List<Widget> dayCells = [];

    // Fill leading empty cells before the first day of the month
    for (int i = 0; i < provider.startOffset; i++) {
      dayCells.add(const SizedBox.shrink());
    }

    // Add day cells for each day of the month
    for (int i = 1; i <= provider.totalDays; i++) {
      dayCells.add(
        CalendarDateCell(
          i: i,
          defaultDecoration: decoration,
          defaultChild: defaultChild,
          userPickedDecoration: userPickedDecoration,
          userPickedChild: userPickedChild,
        ),
      );
    }

    // Fill trailing empty cells to complete the last row
    while (dayCells.length % 7 != 0) {
      dayCells.add(const SizedBox.shrink());
    }

    // Group the cells into weeks
    List<TableRow> rows = [];
    for (int i = 0; i < dayCells.length; i += 7) {
      rows.add(TableRow(children: dayCells.sublist(i, i + 7)));
    }

    return rows;
  }
}

import 'package:flutter/material.dart';
import 'package:m_calendar/provider/calender_table_provider.dart';
import 'package:m_calendar/widgets/calendar_date_cell.dart';
import 'package:provider/provider.dart';

import 'model/marked_date_model.dart';

/// A customizable calendar widget for Flutter supporting single and range date selection.
///
/// [MCalendar] displays a grid of the selected month's days. It provides rich customization
/// via decoration, user-picked states, and child widgets.
///
/// The state is managed with [CalenderTableProvider] and [ChangeNotifierProvider].
class MCalendar extends StatelessWidget {
  /// Creates a styled [MCalendar] widget.
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
    this.cellPadding,
    required this.onUserPicked,
  });

  /// The month to be displayed in the calendar.
  ///
  /// If not provided, defaults to the current month.
  final DateTime? selectedMonth;

  /// The default decoration applied to non-selected and non-marked days.
  final BoxDecoration? decoration;

  /// A list of marked dates with optional decorations and children.
  final List<MarkedDaysModel>? markedDaysList;

  /// The style for the weekday headers (e.g., Mon, Tue).
  final TextStyle? weekNameHeaderStyle;

  /// The default widget for a calendar date cell when no state is active.
  final Widget? defaultChild;

  /// Enables range-based date selection when `true`.
  ///
  /// Defaults to `false` (single-date selection).
  final bool? isRangeSelection;

  /// The decoration to apply when a date is user-selected.
  final BoxDecoration? userPickedDecoration;

  /// The widget to display in a user-picked cell.
  final Widget? userPickedChild;

  /// Padding applied to the cell content.
  final EdgeInsets? cellPadding;

  /// the function return the userPickDate value
  final void Function(List<DateTime>)? onUserPicked;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) =>
              CalenderTableProvider()..initializeMonth(
                selectedMonth ?? DateTime.now(),
                markedDaysList,
                isRangeSelection ?? false,
                onUserPicked: onUserPicked,
              ),
      child: Consumer<CalenderTableProvider>(
        builder: (_, provider, __) {
          return Column(
            children: [
              /// Render weekday headers
              Table(
                children: [
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

                  /// Render calendar day cells in weekly rows
                  ..._generateCalendarRows(
                    provider: provider,
                    decoration: decoration,
                    defaultChild: defaultChild,
                    userPickedDecoration: userPickedDecoration,
                    userPickedChild: userPickedChild,
                    cellPadding: cellPadding,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds all rows (weeks) of the calendar month as a list of [TableRow].
  ///
  /// Handles leading and trailing empty slots, and wraps day cells in rows.
  List<TableRow> _generateCalendarRows({
    Widget? defaultChild,
    Widget? userPickedChild,
    BoxDecoration? decoration,
    BoxDecoration? userPickedDecoration,
    EdgeInsets? cellPadding,
    required CalenderTableProvider provider,
  }) {
    final List<Widget> dayCells = [];

    // Fill initial offset (blank cells before the first day)
    for (int i = 0; i < provider.startOffset; i++) {
      dayCells.add(const SizedBox.shrink());
    }

    // Populate actual date cells
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

    // Complete last row with blank cells if needed
    while (dayCells.length % 7 != 0) {
      dayCells.add(const SizedBox.shrink());
    }

    // Chunk into rows of 7 cells (one per week)
    final List<TableRow> rows = [];
    for (int i = 0; i < dayCells.length; i += 7) {
      rows.add(TableRow(children: dayCells.sublist(i, i + 7)));
    }

    return rows;
  }
}

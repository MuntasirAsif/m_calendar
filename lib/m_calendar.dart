import 'package:flutter/material.dart';
import 'package:m_calendar/provider/calender_table_provider.dart';
import 'package:m_calendar/widgets/calendar_date_cell.dart';
import 'package:provider/provider.dart';

import 'model/selected_date_model.dart';

class MCalendar extends StatelessWidget {
  /// Specifies the initially selected month displayed in the calendar.
  final DateTime? selectedMonth;

  /// Defines the default decoration applied to the calendar widget.
  final BoxDecoration? decoration;

  /// Contains the list of days that are marked as selected in the calendar.
  final List<SelectedDaysModel>? selectedDaysList;

  /// Applies styling to the weekday header names (e.g., Mon, Tue).
  final TextStyle? weekNameHeaderStyle;

  /// The default widget displayed when no specific selection or state is applied.
  final Widget? defaultChild;

  /// Determines whether the calendar uses range-based date selection.
  final bool? isRangeSelection;

  const MCalendar({
    super.key,
    this.selectedMonth,
    this.decoration,
    this.selectedDaysList,
    this.weekNameHeaderStyle,
    this.defaultChild,
    this.isRangeSelection,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalenderTableProvider()
        ..initializeMonth(
          selectedMonth ?? DateTime.now(),
          selectedDaysList,
          isRangeSelection ?? false,
        ),
      child: Scaffold(
        appBar: AppBar(title: const Text('MCalendar')),
        body: Consumer<CalenderTableProvider>(
          builder: (_, provider, __) {
            return Column(
              children: [
                // Render week name headers
                Table(
                  children: [
                    TableRow(
                      children: provider.weekNameList.map((name) {
                        return Center(
                          child: Text(
                            name,
                            style: weekNameHeaderStyle ??
                                const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        );
                      }).toList(),
                    ),
                    // Render calendar days
                    ...generateCalendarRows(
                      provider: provider,
                      decoration: decoration,
                      defaultChild: defaultChild,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Generates table rows with calendar day cells
  List<TableRow> generateCalendarRows({
    Widget? defaultChild,
    BoxDecoration? decoration,
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


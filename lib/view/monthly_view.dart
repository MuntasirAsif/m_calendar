import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/monthly_calender_table_provider.dart';
import '../widgets/calendar_date_cell.dart';
import '../model/marked_date_model.dart';

class MonthlyView extends StatelessWidget {
  final DateTime selectedMonth;
  final BoxDecoration? decoration;
  final List<MarkedDaysModel>? markedDaysList;
  final TextStyle? weekNameHeaderStyle;
  final Widget? defaultChild;
  final BoxDecoration? userPickedDecoration;
  final Widget? userPickedChild;
  final EdgeInsets? cellPadding;
  final void Function(List<DateTime>) onUserPicked;

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

  @override
  Widget build(BuildContext context) {
    return Consumer<MonthlyCalenderTableProvider>(
      builder: (_, provider, __) {
        return Column(
          children: [
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
                ..._generateCalendarRows(provider),
              ],
            ),
          ],
        );
      },
    );
  }

  List<TableRow> _generateCalendarRows(MonthlyCalenderTableProvider provider) {
    final List<Widget> dayCells = [];

    // Fill empty days before 1st of the month
    for (int i = 0; i < provider.startOffset; i++) {
      dayCells.add(const SizedBox.shrink());
    }

    // Add date cells
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

    // Fill empty days after end of month
    while (dayCells.length % 7 != 0) {
      dayCells.add(const SizedBox.shrink());
    }

    // Break into weeks (7 cells per row)
    final List<TableRow> rows = [];
    for (int i = 0; i < dayCells.length; i += 7) {
      rows.add(TableRow(children: dayCells.sublist(i, i + 7)));
    }

    return rows;
  }
}

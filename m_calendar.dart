import 'package:flutter/material.dart';
import 'package:m_calendar/provider/calender_table_provider.dart';
import 'package:provider/provider.dart';
import 'model/selectedDateModel.dart';
import 'widgets/calendar_date_cell.dart';

class MCalendar extends StatelessWidget {
  final DateTime? selectedMonth;
  final BoxDecoration? decoration;
  final List<SelectedDaysModel>? selectedDaysList;

  const MCalendar({
    super.key,
    this.selectedMonth,
    this.decoration,
    this.selectedDaysList,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalenderTableProvider()
        ..initializeMonth(selectedMonth ?? DateTime.now(), selectedDaysList),
      child: Scaffold(
        appBar: AppBar(title: const Text('MCalendar')),
        body: Consumer<CalenderTableProvider>(
          builder: (_, provider, __) {
            return Column(
              children: [
                Table(
                  children: [
                    TableRow(
                      children: provider.weekNameList
                          .map((name) => Center(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                    ...generateCalendarRows(
                      provider: provider,
                      decoration: decoration,
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

  List<TableRow> generateCalendarRows({
    BoxDecoration? decoration,
    required CalenderTableProvider provider,
  }) {
    List<Widget> dayCells = [];

    for (int i = 0; i < provider.startOffset; i++) {
      dayCells.add(const SizedBox.shrink());
    }

    for (int i = 1; i <= provider.totalDays; i++) {
      dayCells.add(
        CalendarDateCell(i: i, defaultDecoration: decoration),
      );
    }

    while (dayCells.length % 7 != 0) {
      dayCells.add(const SizedBox.shrink());
    }

    List<TableRow> rows = [];
    for (int i = 0; i < dayCells.length; i += 7) {
      rows.add(TableRow(children: dayCells.sublist(i, i + 7)));
    }

    return rows;
  }
}

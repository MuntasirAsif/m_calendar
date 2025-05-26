import 'package:flutter/material.dart';
import 'package:m_calendar/provider/weekly_calendar_table_provider.dart';
import 'package:m_calendar/widgets/calendar_week_cell.dart';
import 'package:provider/provider.dart';
import '../model/marked_date_model.dart';

class WeeklyView extends StatelessWidget {
  final DateTime selectedMonth;
  final BoxDecoration? decoration;
  final List<MarkedDaysModel>? markedDaysList;
  final TextStyle? weekNameHeaderStyle;
  final Widget? defaultChild;
  final BoxDecoration? userPickedDecoration;
  final Widget? userPickedChild;
  final EdgeInsets? cellPadding;
  final void Function(List<DateTime>) onUserPicked;
  final bool isRangeSelection;

  const WeeklyView({
    required this.selectedMonth,
    required this.onUserPicked,
    this.markedDaysList,
    this.weekNameHeaderStyle,
    this.userPickedDecoration,
    this.userPickedChild,
    this.cellPadding,
    this.decoration,
    this.defaultChild,
    this.isRangeSelection = false,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return Consumer<WeeklyCalenderTableProvider>(
      builder: (_, provider, __) {
        final monthWeekMap = provider.monthWeekMap;
        final months = monthWeekMap.keys.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week headers
            Padding(
              padding: const EdgeInsets.only(left: 100, bottom: 8),
              child: Row(
                children: List.generate(5, (i) => Expanded(
                  child: Center(
                    child: Text('Week ${i + 1}',
                      style: weekNameHeaderStyle ??
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                )),
              ),
            ),

            // Month rows
            ...months.map((monthLabel) {
              final weeks = monthWeekMap[monthLabel]!;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month label
                    SizedBox(
                      width: 80,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          monthLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Week columns
                    ...List.generate(5, (i) {
                      final week = i < weeks.length ? weeks[i] : [];

                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: week
                                .where((d) => d.month == provider.monthNameToNumber(monthLabel))
                                .map((date) {
                              return WeeklyCalendarDateCell(
                                i: date.day,
                                isSelected: provider.userPicked == date.day,
                                onTap: () => provider.toggleUserPicked(date),
                                defaultDecoration: decoration,
                                defaultChild: defaultChild,
                                userPickedDecoration: userPickedDecoration,
                                userPickedChild: userPickedChild,
                                cellPadding: cellPadding,
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

}

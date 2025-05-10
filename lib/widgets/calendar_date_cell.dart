import 'package:flutter/material.dart';
import 'package:m_calendar/provider/calender_table_provider.dart';
import 'package:provider/provider.dart';
import '../model/selectedDateModel.dart';

class CalendarDateCell extends StatelessWidget {
  final int i;
  final BoxDecoration? defaultDecoration;

  const CalendarDateCell({super.key, required this.i, this.defaultDecoration});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalenderTableProvider>(context, listen: false);

    final selectedDecoration =
        provider.selectedDaysList
            .firstWhere(
              (model) => model.selectedDateList.contains(i),
              orElse:
                  () => SelectedDaysModel(
                    selectedDateList: [],
                    decoration:
                        defaultDecoration ??
                        BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                  ),
            )
            .decoration;

    final child =
        provider.selectedDaysList
            .firstWhere(
              (model) => model.selectedDateList.contains(i),
              orElse:
                  () => SelectedDaysModel(
                    selectedDateList: [],
                    decoration:
                        defaultDecoration ??
                        BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                  ),
            )
            .child;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: selectedDecoration,
      child: child ?? Center(child: Text(i.toString())),
    );
  }
}

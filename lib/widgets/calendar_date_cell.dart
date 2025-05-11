import 'package:flutter/material.dart';
import 'package:m_calendar/provider/calender_table_provider.dart';
import 'package:provider/provider.dart';
import '../model/selected_date_model.dart';

class CalendarDateCell extends StatelessWidget {
  final int i;
  final BoxDecoration? defaultDecoration;
  final Widget? defaultChild;
  final Widget? userSelectedItemStyle;

  const CalendarDateCell({
    super.key,
    required this.i,
    this.defaultDecoration,
    this.defaultChild,
    this.userSelectedItemStyle,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalenderTableProvider>(context);

    // Find if this day is in the custom selected list
    final selectedModel = provider.selectedDaysList.firstWhere(
          (model) => model.selectedDateList.contains(i),
      orElse: () => SelectedDaysModel(
        selectedDateList: [],
        decoration: defaultDecoration ??
            BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
      ),
    );

    final selectedDecoration = selectedModel.decoration;
    final child = selectedModel.child;

    // Determine if this day is selected
    final bool isSelected = provider.isRangeSelection
        ? provider.isInRange(i)
        : provider.userPicked == i;

    return GestureDetector(
      onTap: () => provider.toggleUserPicked(i),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(4),
        decoration: selectedDecoration.copyWith(
          color: isSelected ? Colors.teal.shade400 : selectedDecoration.color,
        ),
        child: child ?? defaultChild ?? Center(child: Text(i.toString())),
      ),
    );
  }
}


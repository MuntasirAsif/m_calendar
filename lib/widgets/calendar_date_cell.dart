import 'package:flutter/material.dart';
import 'package:m_calendar/provider/calender_table_provider.dart';
import 'package:provider/provider.dart';
import '../model/selectedDateModel.dart';

class CalendarDateCell extends StatelessWidget {
  final int i;
  final BoxDecoration? defaultDecoration;
  final Widget? defaultChild;
  final Widget? userSelectedDecoration;

  const CalendarDateCell({
    super.key,
    required this.i,
    this.defaultDecoration,
    this.defaultChild,
    this.userSelectedDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalenderTableProvider>(
      context,
    ); // listen: true

    // Check for custom decorations
    final selectedModel = provider.selectedDaysList.firstWhere(
      (model) => model.selectedDateList.contains(i),
      orElse:
          () => SelectedDaysModel(
            selectedDateList: [],
            decoration:
                defaultDecoration ??
                BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
          ),
    );

    final selectedDecoration = selectedModel.decoration;
    final child = selectedModel.child;

    // Use default or override based on selection mode
    final bool isSelected =
        provider.isRangeSelection
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

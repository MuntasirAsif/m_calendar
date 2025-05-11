import 'package:flutter/material.dart';
import 'package:m_calendar/provider/calender_table_provider.dart';
import 'package:provider/provider.dart';
import '../model/selected_date_model.dart';

/// A widget that represents a single date cell in the calendar grid.
///
/// This widget handles its own selection logic based on the [CalenderTableProvider]
/// and applies custom decorations or children if provided.
class CalendarDateCell extends StatelessWidget {

  /// Creates a [CalendarDateCell] widget.
  ///
  /// This widget displays a styled date cell that reacts to user interaction
  /// and updates its appearance based on selection status.
  const CalendarDateCell({
    super.key,
    required this.i,
    this.defaultDecoration,
    this.defaultChild,
    this.userSelectedItemStyle,
  });
  /// The index or identifier for this date cell (usually the day number).
  final int i;

  /// The default decoration to apply when no specific decoration is selected.
  final BoxDecoration? defaultDecoration;

  /// The default child widget to display in the cell when no specific child is set.
  final Widget? defaultChild;

  /// A custom widget to display when the cell is selected by the user.
  final Widget? userSelectedItemStyle;

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

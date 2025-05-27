import 'package:flutter/material.dart';

/// A widget that represents an individual date cell in the weekly calendar view.
///
/// This widget is used to display the start and end date of a week in the calendar.
/// It provides the functionality to display a date, highlight selected dates, and
/// trigger actions when a date is tapped.
class WeeklyCalendarDateCell extends StatelessWidget {
  /// Creates a new instance of the WeeklyCalendarDateCell widget.
  const WeeklyCalendarDateCell({
    super.key,
    required this.firstDate,
    required this.isSelected,
    this.onTap,
    this.defaultDecoration,
    this.defaultChild,
    this.userPickedDecoration,
    this.userPickedChild,
    this.cellPadding,
    required this.lastDate,
  });

  /// The first date of the week (used to display the start day).
  final DateTime firstDate;

  /// The last date of the week (used to display the end day).
  final DateTime lastDate;

  /// A flag indicating whether this date cell is selected.
  final bool isSelected;

  /// A callback that is triggered when the cell is tapped.
  final VoidCallback? onTap;

  /// The default decoration applied to the cell when it is not selected.
  final BoxDecoration? defaultDecoration;

  /// The default widget to display inside the cell when it is not selected.
  final Widget? defaultChild;

  /// The decoration applied to the cell when it is selected.
  final BoxDecoration? userPickedDecoration;

  /// The widget displayed inside the cell when it is selected.
  final Widget? userPickedChild;

  /// The padding applied around the content inside the cell.
  final EdgeInsets? cellPadding;

  @override
  Widget build(BuildContext context) {
    // Determines if the date cell is empty (e.g., if the date is not assigned).
    final isBlank = firstDate.year == 0;

    // Decides the decoration based on whether the cell is selected or not.
    final decoration =
        isSelected
            ? userPickedDecoration ??
                BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(6),
                )
            : defaultDecoration ?? const BoxDecoration();

    // Sets the child content for the cell, depending on whether the cell is blank or selected.
    final child =
        isBlank
            ? const SizedBox.shrink() // If the cell is blank, show nothing
            : isSelected
            ? userPickedChild ??
                Text(
                  '${firstDate.day}-${lastDate.day}', // Display the date range
                  style: const TextStyle(color: Colors.white),
                )
            : defaultChild ??
                Text(
                  '${firstDate.day}-${lastDate.day}',
                ); // Display default date range

    return GestureDetector(
      onTap: isBlank ? null : onTap, // Disable tap if the cell is blank
      child: Container(
        padding:
            cellPadding ??
            const EdgeInsets.all(6), // Padding for content inside the cell
        decoration: decoration,
        child: Center(child: child), // Center the content inside the cell
      ),
    );
  }
}

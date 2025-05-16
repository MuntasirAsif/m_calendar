import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/marked_date_model.dart';
import '../provider/calender_table_provider.dart';
import '../utils/range_decoration.dart';

/// A widget that represents a single selectable day cell in a calendar grid.
///
/// [CalendarDateCell] determines its decoration and content based on:
/// - Whether it's part of a marked list (`MarkedDaysModel`)
/// - Whether it is picked by the user
/// - Whether it lies within a selected range (if enabled)
///
/// It supports both single and range selections, with custom styling options.
class CalendarDateCell extends StatelessWidget {
  /// Creates a date cell for the calendar with customizable styling and content.
  ///
  /// [i] is the day number (1-based). The other parameters allow customization
  /// of decorations and child widgets for default, picked, and selected states.
  const CalendarDateCell({
    super.key,
    required this.i,
    this.defaultDecoration,
    this.defaultChild,
    this.userSelectedItemStyle,
    this.userPickedDecoration,
    this.userPickedChild,
  });

  /// The day of the month represented by this cell (1-based index).
  final int i;

  /// Default decoration applied when the cell is not marked or picked.
  final BoxDecoration? defaultDecoration;

  /// Default widget displayed inside the cell when not marked or picked.
  final Widget? defaultChild;

  /// Widget displayed when this cell is user-selected (picked or in range).
  final Widget? userSelectedItemStyle;

  /// Custom decoration when the cell is picked by the user.
  final BoxDecoration? userPickedDecoration;

  /// Custom widget displayed when the cell is picked by the user.
  final Widget? userPickedChild;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalenderTableProvider>(context);

    final selectedModel = provider.selectedDaysList.firstWhere(
      (model) => model.selectedDateList.contains(i),
      orElse:
          () => MarkedDaysModel(
            selectedDateList: [],
            decoration:
                defaultDecoration ??
                BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
          ),
    );

    final bool isUserPicked = provider.userPicked == i;
    final bool isInRange = provider.isRangeSelection && provider.isInRange(i);

    final BoxDecoration finalDecoration =
        isInRange
            ? getRangeDecoration(
              context: context,
              i: i,
              rangeStart: provider.rangeStart,
              rangeEnd: provider.rangeEnd,
              defaultDecoration: defaultDecoration,
              baseColor: userPickedDecoration?.color ?? Colors.teal.shade400,
            )
            : isUserPicked
            ? userPickedDecoration ??
                selectedModel.decoration.copyWith(color: Colors.teal.shade400)
            : selectedModel.decoration;

    final Widget finalChild =
        (isUserPicked || isInRange)
            ? userPickedChild ??
                userSelectedItemStyle ??
                defaultChild ??
                Center(child: Text(i.toString()))
            : selectedModel.child ??
                defaultChild ??
                Center(child: Text(i.toString()));

    final EdgeInsets finalMargin =
        isInRange
            ? const EdgeInsets.symmetric(horizontal: 0, vertical: 4)
            : const EdgeInsets.all(4);

    return GestureDetector(
      onTap: () => provider.toggleUserPicked(i),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: finalMargin,
        decoration: finalDecoration,
        child: finalChild,
      ),
    );
  }
}

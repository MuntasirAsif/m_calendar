import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/marked_date_model.dart';
import '../provider/monthly_calender_table_provider.dart';
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
    this.cellPadding,
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

  /// Padding applied to the cell content.
  final EdgeInsets? cellPadding;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MonthlyCalenderTableProvider>(context);
    final currentDate = DateTime(
      provider.selectedMonth.year,
      provider.selectedMonth.month,
      i,
    );

    final selectedModel = provider.selectedDaysList.firstWhere(
      (model) => model.selectedDateList.any(
        (d) =>
            d.year == currentDate.year &&
            d.month == currentDate.month &&
            d.day == currentDate.day,
      ),
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

    BoxDecoration finalDecoration =
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
    final EdgeInsets finalPadding =
        isInRange && cellPadding != null
            ? EdgeInsets.zero
            : cellPadding ?? const EdgeInsets.all(12);

    bool rangePickHold =
        provider.rangeStart != null &&
        provider.rangeEnd == null &&
        provider.rangeStart == i;
    finalDecoration =
        rangePickHold
            ? (userPickedDecoration != null
                ? userPickedDecoration!.copyWith(
                  color: userPickedDecoration!.color?.withValues(alpha: 128),
                )
                : selectedModel.decoration.copyWith(
                  color: Colors.teal.shade400.withValues(alpha: 128),
                ))
            : finalDecoration;

    return GestureDetector(
      onTap: () => provider.toggleUserPicked(i),
      child: Container(
        padding: finalPadding,
        margin: finalMargin,
        decoration: finalDecoration,
        child: finalChild,
      ),
    );
  }
}

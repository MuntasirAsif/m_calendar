import 'package:flutter/material.dart';
import 'package:m_calendar/provider/calender_table_provider.dart';
import 'package:provider/provider.dart';
import '../model/marked_date_model.dart';

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
    this.userPickedDecoration,
    this.userPickedChild,
  });

  /// The index or identifier for this date cell (usually the day number).
  final int i;

  /// The default decoration to apply when no specific decoration is selected.
  final BoxDecoration? defaultDecoration;

  /// The default child widget to display in the cell when no specific child is set.
  final Widget? defaultChild;

  /// A custom widget to display when the cell is selected by the user.
  final Widget? userSelectedItemStyle;

  /// A custom decoration to apply when the user selects this cell.
  final BoxDecoration? userPickedDecoration;

  /// A custom widget to display when the user selects this cell.
  final Widget? userPickedChild;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalenderTableProvider>(context);

    // Find if this day is in the custom selected list
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

    final bool isSelected =
        provider.isRangeSelection
            ? provider.isInRange(i)
            : provider.userPicked == i;

    // Choose decoration based on user-picked state
    final BoxDecoration finalDecoration = provider.isRangeSelection
        ? getRangeDecoration(context)
        : (provider.userPicked == i
        ? userPickedDecoration ??
        selectedModel.decoration.copyWith(color: Colors.teal.shade400)
        : selectedModel.decoration);


    // Choose child widget
    final Widget finalChild =
        isSelected
            ? userPickedChild ??
                userSelectedItemStyle ??
                defaultChild ??
                Center(child: Text(i.toString()))
            : selectedModel.child ??
                defaultChild ??
                Center(child: Text(i.toString()));

    final Color baseColor = (userPickedDecoration?.color ?? Colors.teal);
    final BoxDecoration adjustedDecoration = finalDecoration.copyWith(
      color: baseColor.withOpacity(0.5),
    );

    final bool isInRange = provider.rangeStart != null &&
        provider.rangeEnd != null &&
        provider.rangeStart! <= i &&
        provider.rangeEnd! >= i;

    final EdgeInsets finalMargin = isInRange
        ? const EdgeInsets.symmetric(horizontal: 0, vertical: 4)
        : const EdgeInsets.all(4);

    return GestureDetector(
      onTap: () => provider.toggleUserPicked(i),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: finalMargin,
        decoration:
            provider.rangeEnd == null && provider.rangeStart == i
                ? adjustedDecoration
                : finalDecoration,
        child: finalChild,
      ),
    );
  }

  BoxDecoration getRangeDecoration(BuildContext context) {
    final provider = Provider.of<CalenderTableProvider>(context);

    final baseColor = userPickedDecoration?.color ??Colors.teal.shade400;

    // Start of the range
    if (i == provider.rangeStart) {
      return BoxDecoration(
        color: baseColor,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(32)),
      );
    }

    // End of the range
    if (i == provider.rangeEnd) {
      return BoxDecoration(
        color: baseColor,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(32)),
      );
    }

    // In the middle of the range
    if (provider.isInRange(i)) {
      return BoxDecoration(color: baseColor.withOpacity(0.5), borderRadius: BorderRadius.zero);
    }

    // Default style
    return defaultDecoration ??
        BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        );
  }
}

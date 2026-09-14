import 'package:flutter/material.dart';
import 'marked_date_model.dart';

/// Represents the visual and interactive state of a calendar day cell.
///
/// Passed to [CalendarDayBuilder] so developers can render custom widgets
/// based on selection, range, marked, today, and disabled status.
class DayState {
  /// Creates a [DayState] with the given cell flags and models.
  const DayState({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.isInRange,
    required this.isRangeStart,
    required this.isRangeEnd,
    this.markedModel,
  });

  /// The date represented by this cell.
  final DateTime date;

  /// Whether this day is currently selected (single selection or endpoint of range).
  final bool isSelected;

  /// Whether this day represents today's date.
  final bool isToday;

  /// Whether this day is disabled (cannot be interacted with).
  final bool isDisabled;

  /// Whether this day is inside the selected date range.
  final bool isInRange;

  /// Whether this day is the starting date of the selected range.
  final bool isRangeStart;

  /// Whether this day is the ending date of the selected range.
  final bool isRangeEnd;

  /// The [MarkedDaysModel] that applies to this date, if any.
  final MarkedDaysModel? markedModel;
}

/// A builder function that creates a custom widget for a calendar day cell.
///
/// If this builder returns `null`, the default cell presentation is used.
typedef CalendarDayBuilder =
    Widget? Function(BuildContext context, DateTime date, DayState state);

import 'package:flutter/material.dart';

/// A model that defines custom styling and content for a group of selected dates
/// in the calendar.
///
/// This can be used to apply a specific [decoration] or [child] widget
/// to multiple date cells identified by [selectedDateList].
class SelectedDaysModel {
  /// Creates a [SelectedDaysModel] with the given [selectedDateList] and [decoration].
  ///
  /// Optionally, a custom [child] widget can be provided to display in the date cells.
  SelectedDaysModel({
    required this.selectedDateList,
    required this.decoration,
    this.child,
  });

  /// A list of day indices (e.g., 1–31) that are considered selected.
  final List<int> selectedDateList;

  /// The visual decoration to apply to the selected date cells.
  final BoxDecoration decoration;

  /// An optional widget to be displayed in the selected cells
  /// instead of the default date text.
  final Widget? child;
}

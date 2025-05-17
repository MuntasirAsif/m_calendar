import 'package:flutter/material.dart';

/// A model class representing a set of marked days on a calendar UI.
///
/// The [MarkedDaysModel] is used to define which days should be visually
/// decorated on a calendar, along with optional custom widgets.
class MarkedDaysModel {
  /// Creates a [MarkedDaysModel] with a list of selected dates,
  /// a decoration to apply, and an optional child widget.
  ///
  /// - [selectedDateList] should contain full [DateTime] values.
  /// - [decoration] is the visual styling applied to those marked days.
  /// - [child] is an optional widget to overlay on those decorated days.
  MarkedDaysModel({
    required this.selectedDateList,
    required this.decoration,
    this.child,
  });

  /// A list of [DateTime] objects representing the exact days
  /// that should be marked on the calendar.
  final List<DateTime> selectedDateList;

  /// The visual decoration to apply to the marked days.
  final BoxDecoration decoration;

  /// An optional widget to display on top of the decorated day cell.
  final Widget? child;
}

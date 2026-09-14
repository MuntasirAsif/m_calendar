import 'package:flutter/material.dart';

import '../model/marked_date_model.dart';

/// A provider that manages state for a horizontal calendar.
///
/// It handles:
/// - Currently selected month
/// - Currently selected day
/// - Marked days
/// - User date selection callbacks
class HorizontalCalendarProvider extends ChangeNotifier {
  /// Creates a new instance of [HorizontalCalendarProvider].
  ///
  /// [isRangeSelection] determines whether the calendar supports range selection.
  ///
  /// [onUserPicked] is triggered when user selects a date.
  ///
  /// [markedDaysList] contains optional marked dates that can be highlighted.
  HorizontalCalendarProvider({required this.onUserPicked, this.markedDaysList});

  /// Internal storage for selected month.
  DateTime _selectedMonth = DateTime.now();

  /// Internal storage for selected day.
  DateTime _selectedDay = DateTime.now();

  /// Optional list of marked days to highlight in calendar.
  final List<MarkedDaysModel>? markedDaysList;

  /// Callback triggered when user selects date(s).
  final void Function(DateTime) onUserPicked;

  /// Currently selected month.
  DateTime get selectedMonth => _selectedMonth;

  /// Currently selected day.
  DateTime get selectedDay => _selectedDay;

  /// Updates the selected month and notifies listeners.
  ///
  /// Only the year and month of [month] are used; day and time are ignored.
  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  /// Returns all days available in the currently selected month.
  ///
  /// Example:
  /// If selected month is February 2026,
  /// this returns all dates from Feb 1 → Feb 28/29.
  List<DateTime> get daysInMonth {
    final totalDays =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;

    return List.generate(
      totalDays,
      (index) => DateTime(_selectedMonth.year, _selectedMonth.month, index + 1),
    );
  }

  /// Updates the selected day and triggers [onUserPicked].
  void setSelectedDay(DateTime day) {
    _selectedDay = day;

    onUserPicked(day);

    notifyListeners();
  }

  /// Clears the current selection.
  void clearSelection() {
    _selectedDay = DateTime(0);
    notifyListeners();
  }

  /// Returns the first [MarkedDaysModel] that contains [date], or `null`
  /// if the date is not marked.
  ///
  /// Dates are compared by year/month/day only; time is ignored.
  MarkedDaysModel? markedModelFor(DateTime date) {
    final list = markedDaysList;
    if (list == null) return null;

    for (final marked in list) {
      final matches = marked.selectedDateList.any(
        (d) =>
            d.year == date.year && d.month == date.month && d.day == date.day,
      );
      if (matches) return marked;
    }
    return null;
  }

  /// Returns `true` if the given [date] exists inside [markedDaysList].
  ///
  /// Used to visually highlight marked dates in UI.
  bool isMarked(DateTime date) => markedModelFor(date) != null;
}

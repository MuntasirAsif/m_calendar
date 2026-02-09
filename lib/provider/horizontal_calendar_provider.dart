import 'package:flutter/material.dart';

import '../model/marked_date_model.dart';

/// A provider for a horizontal calendar view.
class HorizontalCalendarProvider extends ChangeNotifier {
  /// Creates a new instance of [HorizontalCalendarProvider].
  HorizontalCalendarProvider({
    required this.isRangeSelection,
    required this.onUserPicked,
    this.markedDaysList,
  });
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  /// Creates a new instance of [HorizontalCalendarProvider].
  final bool isRangeSelection;

  /// The list of marked days.
  final List<MarkedDaysModel>? markedDaysList;

  /// The callback function to handle user-picked dates.
  final void Function(List<DateTime>) onUserPicked;

  /// The selected month.
  DateTime get selectedMonth => _selectedMonth;

  /// The selected day.
  DateTime get selectedDay => _selectedDay;

  /// Sets the selected month.
  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
  }

  /// Returns a list of days in the selected month.
  List<DateTime> get daysInMonth {
    final totalDays =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;

    return List.generate(
      totalDays,
      (index) => DateTime(_selectedMonth.year, _selectedMonth.month, index + 1),
    );
  }

  /// Sets the selected day.
  void setSelectedDay(DateTime day) {
    _selectedDay = day;

    onUserPicked([day]);

    notifyListeners();
  }

  /// Checks if a day is marked.
  bool isMarked(DateTime date) {
    if (markedDaysList == null) return false;

    for (var marked in markedDaysList!) {
      if (marked.selectedDateList.any(
        (d) =>
            d.year == date.year && d.month == date.month && d.day == date.day,
      )) {
        return true;
      }
    }
    return false;
  }
}

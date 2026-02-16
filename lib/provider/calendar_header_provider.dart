import 'package:flutter/material.dart';

/// Provider that holds the currently selected month used by the
/// calendar header UI and exposes helpers to change it.
///
/// Use this provider to read or change the month shown in the
/// month/year picker UI.
class CalendarHeaderProvider extends ChangeNotifier {
  /// Creates a [CalendarHeaderProvider] initialized to [initialMonth].
  ///
  /// Only the year and month components of [initialMonth] are used.
  CalendarHeaderProvider(DateTime initialMonth) {
    _selectedMonth = DateTime(initialMonth.year, initialMonth.month);
  }

  late DateTime _selectedMonth;

  /// The currently selected month (year + month, day is ignored).
  DateTime get selectedMonth => _selectedMonth;

  /// Replace the currently selected month and notify listeners.
  void setMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  /// Move the selected month back by one month and notify listeners.
  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  /// Move the selected month forward by one month and notify listeners.
  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }
}

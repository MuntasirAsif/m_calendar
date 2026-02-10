import 'package:flutter/material.dart';

/// Manages the selected month for calendar header
class CalendarHeaderProvider extends ChangeNotifier {
  CalendarHeaderProvider(DateTime initialMonth) {
    _selectedMonth = DateTime(initialMonth.year, initialMonth.month);
  }

  late DateTime _selectedMonth;

  DateTime get selectedMonth => _selectedMonth;

  /// Set a new month
  void setMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  /// Go to previous month
  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  /// Go to next month
  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }
}

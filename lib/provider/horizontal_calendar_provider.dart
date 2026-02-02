import 'package:flutter/material.dart';

/// A provider that handles horizontal calendar logic.
class HorizontalCalendarProvider extends ChangeNotifier {
  DateTime _seletedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  /// Getter for the selected month.
  DateTime get selectedMonth => _seletedMonth;

  /// Getter for the selected day.
  DateTime get selectedDay => _selectedDay;

  List<int> get daysInMonth => _daysInMonth(_seletedMonth);

  /// Setter for the selected month.
  void setSelectedMonth(DateTime month) {
    _seletedMonth = month;
    notifyListeners();
  }

  List<int> _daysInMonth(DateTime month) {
    final firstDayThisMonth = DateTime(month.year, month.month, 1);
    final firstDayNextMonth = DateTime(month.year, month.month + 1, 1);
    final daysCount = firstDayNextMonth.difference(firstDayThisMonth).inDays;
    return List<int>.generate(daysCount, (index) => index + 1);
  }

  /// Setter for the selected day.
  void setSelectedDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }
}

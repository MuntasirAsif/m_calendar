import 'package:flutter/material.dart';
import '../model/marked_date_model.dart';

class WeeklyCalenderTableProvider extends ChangeNotifier {
  late DateTime _selectedMonth;
  late int _totalDays;
  late int _startOffset;

  int? _userPicked;
  int? _rangeStart;
  int? _rangeEnd;

  bool isRangeSelection = false;
  List<MarkedDaysModel> selectedDaysList = [];
  void Function(List<DateTime>)? _onUserPickedCallback;

  DateTime get selectedMonth => _selectedMonth;
  int get totalDays => _totalDays;
  int get startOffset => _startOffset;
  int? get userPicked => _userPicked;

  Map<String, List<List<DateTime>>> get monthWeekMap => _generateWeeksByMonth();

  void initializeMonth(
      DateTime selectedMonth,
      List<MarkedDaysModel>? customList,
      bool isRange, {
        void Function(List<DateTime>)? onUserPicked,
      }) {
    _selectedMonth = selectedMonth;
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    _startOffset = (firstDay.weekday % 7);
    _totalDays = DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month);
    isRangeSelection = isRange;
    _onUserPickedCallback = onUserPicked;
    selectedDaysList = customList ?? [];
    _userPicked = null;
    _rangeStart = null;
    _rangeEnd = null;
    notifyListeners();
  }

  void toggleUserPicked(DateTime date) {
    _userPicked = date.day;
    _onUserPickedCallback?.call([date]);
    notifyListeners();
  }

  Map<String, List<List<DateTime>>> _generateWeeksByMonth() {
    final Map<String, List<List<DateTime>>> result = {};
    for (int m = 5; m >= 0; m--) {
      final current = DateTime(_selectedMonth.year, _selectedMonth.month - m);
      final label = _monthName(current.month);
      final daysInMonth = DateUtils.getDaysInMonth(current.year, current.month);
      final startOffset = DateTime(current.year, current.month, 1).weekday % 7;

      List<DateTime> allDates = [];

      for (int i = 0; i < startOffset; i++) {
        allDates.add(DateTime(0));
      }
      for (int i = 1; i <= daysInMonth; i++) {
        allDates.add(DateTime(current.year, current.month, i));
      }
      while (allDates.length % 7 != 0) {
        allDates.add(DateTime(0));
      }

      List<List<DateTime>> weeks = [];
      for (int i = 0; i < allDates.length; i += 7) {
        weeks.add(allDates.sublist(i, i + 7));
      }

      result[label] = weeks;
    }

    return result;
  }

  String _monthName(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month - 1];
  }

  int monthNameToNumber(String label) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months.indexOf(label) + 1;
  }
}

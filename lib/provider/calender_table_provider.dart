import 'package:flutter/material.dart';
import '../model/selectedDateModel.dart';

class CalenderTableProvider extends ChangeNotifier {
  final List<String> weekNameList = [
    'Sat',
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
  ];

  late int _startOffset;
  late int _totalDays;
  late DateTime _selectedMonth;

  List<SelectedDaysModel> selectedDaysList = [];

  int get startOffset => _startOffset;
  int get totalDays => _totalDays;
  DateTime get selectedMonth => _selectedMonth;

  void initializeMonth(
    DateTime selectedMonth, [
    List<SelectedDaysModel>? customList,
  ]) {
    _selectedMonth = selectedMonth;
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    _startOffset = (firstDay.weekday % 7);
    _totalDays = DateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    if (customList != null) {
      selectedDaysList = customList;
    }
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../model/selectedDateModel.dart';

class CalenderTableProvider extends ChangeNotifier {
  final List<String> weekNameList = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  late int _startOffset;
  late int _totalDays;
  late DateTime _selectedMonth;

  int? _userPicked;
  int? _rangeStart;
  int? _rangeEnd;

  bool isRangeSelection = false;

  List<SelectedDaysModel> selectedDaysList = [];

  int get startOffset => _startOffset;
  int get totalDays => _totalDays;
  DateTime get selectedMonth => _selectedMonth;
  int? get userPicked => _userPicked;
  int? get rangeStart => _rangeStart;
  int? get rangeEnd => _rangeEnd;

  void initializeMonth(
      DateTime selectedMonth,
      List<SelectedDaysModel>? customList,
      [bool isRange = false]
      ) {
    _selectedMonth = selectedMonth;
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    _startOffset = (firstDay.weekday % 7);
    _totalDays = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
    isRangeSelection = isRange;

    if (customList != null) {
      selectedDaysList = customList;
    }

    _userPicked = null;
    _rangeStart = null;
    _rangeEnd = null;
    notifyListeners();
  }


  void toggleUserPicked(int index) {
    if (isRangeSelection) {
      if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
        _rangeStart = index;
        _rangeEnd = null;
      } else if (_rangeStart != null && _rangeEnd == null) {
        _rangeEnd = index;

        if (_rangeEnd! < _rangeStart!) {
          final temp = _rangeStart;
          _rangeStart = _rangeEnd;
          _rangeEnd = temp;
        }
      }
    } else {
      _userPicked = index;
    }
    notifyListeners();
  }

  bool isInRange(int index) {
    if (_rangeStart != null && _rangeEnd != null) {
      return index >= _rangeStart! && index <= _rangeEnd!;
    }
    return false;
  }

  void toggleSelectionMode(bool selectionMode) {
    isRangeSelection = selectionMode;
    isRangeSelection = !isRangeSelection;
    _userPicked = null;
    _rangeStart = null;
    _rangeEnd = null;
    notifyListeners();
  }
}

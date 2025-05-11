import 'package:flutter/material.dart';
import '../model/selected_date_model.dart';

/// A provider class that manages the state of a calendar table, including
/// selected dates, current month, and selection mode (single or range).
///
/// This provider supports notifying listeners when changes occur to update
/// UI components accordingly.
class CalenderTableProvider extends ChangeNotifier {
  /// List of week day names, starting with Saturday.
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

  int? _userPicked;
  int? _rangeStart;
  int? _rangeEnd;

  /// Determines whether range selection is enabled.
  bool isRangeSelection = false;

  /// List of custom selected day models with decorations or children.
  List<SelectedDaysModel> selectedDaysList = [];

  /// The offset index of the first day in the month (0-6 based on weekday).
  int get startOffset => _startOffset;

  /// The total number of days in the selected month.
  int get totalDays => _totalDays;

  /// The currently selected month.
  DateTime get selectedMonth => _selectedMonth;

  /// The single date selected by the user (when range selection is off).
  int? get userPicked => _userPicked;

  /// The starting index of the selected date range.
  int? get rangeStart => _rangeStart;

  /// The ending index of the selected date range.
  int? get rangeEnd => _rangeEnd;

  /// Initializes the calendar with a given month and an optional custom date list.
  ///
  /// [selectedMonth] defines the month to display.
  /// [customList] is an optional list of [SelectedDaysModel] to mark special days.
  /// [isRange] enables range selection mode if true.
  void initializeMonth(
    DateTime selectedMonth,
    List<SelectedDaysModel>? customList, [
    bool isRange = false,
  ]) {
    _selectedMonth = selectedMonth;
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    _startOffset = (firstDay.weekday % 7);
    _totalDays = DateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    isRangeSelection = isRange;

    if (customList != null) {
      selectedDaysList = customList;
    }

    _userPicked = null;
    _rangeStart = null;
    _rangeEnd = null;
    notifyListeners();
  }

  /// Handles user interaction for selecting a date or a range of dates.
  ///
  /// [index] is the calendar cell index corresponding to the selected day.
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

  /// Returns true if the given [index] is within the selected date range.
  bool isInRange(int index) {
    if (_rangeStart != null && _rangeEnd != null) {
      return index >= _rangeStart! && index <= _rangeEnd!;
    }
    return false;
  }

  /// Toggles the calendar between single and range selection modes.
  ///
  /// [selectionMode] is the new mode to switch to.
  void toggleSelectionMode(bool selectionMode) {
    isRangeSelection = selectionMode;
    isRangeSelection = !isRangeSelection;
    _userPicked = null;
    _rangeStart = null;
    _rangeEnd = null;
    notifyListeners();
  }
}

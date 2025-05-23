import 'package:flutter/material.dart';
import '../model/marked_date_model.dart';

/// A [ChangeNotifier] that manages calendar state, including selected month,
/// selected dates, and range selection.
///
/// Used to control and update a custom calendar widget.
class CalenderTableProvider extends ChangeNotifier {
  /// A fixed list of week day labels starting from Saturday.
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

  /// Whether range selection is enabled.
  bool isRangeSelection = false;

  /// A list of dates marked with custom decoration and optional child widgets.
  List<MarkedDaysModel> selectedDaysList = [];

  /// Optional callback invoked when the user picks a date or range.
  void Function(List<DateTime>)? _onUserPickedCallback;

  /// Number of blank leading cells before the first day of the month.
  int get startOffset => _startOffset;

  /// Total number of days in the currently selected month.
  int get totalDays => _totalDays;

  /// The selected month displayed in the calendar.
  DateTime get selectedMonth => _selectedMonth;

  /// The currently selected day for single-date mode (1-based).
  int? get userPicked => _userPicked;

  /// Start index of the user-selected range (1-based).
  int? get rangeStart => _rangeStart;

  /// End index of the user-selected range (1-based).
  int? get rangeEnd => _rangeEnd;

  /// Initializes the calendar with a specific [selectedMonth], optional marked days [customList],
  /// and a selection mode flag [isRange]. Also registers an optional [onUserPicked] callback.
  void initializeMonth(
    DateTime selectedMonth,
    List<MarkedDaysModel>? customList,
    bool isRange, {
    void Function(List<DateTime>)? onUserPicked,
  }) {
    _selectedMonth = selectedMonth;
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    _startOffset = (firstDay.weekday % 7);
    _totalDays = DateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    isRangeSelection = isRange;
    _onUserPickedCallback = onUserPicked;

    if (customList != null) {
      selectedDaysList = customList;
    }

    _userPicked = null;
    _rangeStart = null;
    _rangeEnd = null;
    notifyListeners();
  }

  /// Toggles the selection state when a user taps a calendar day cell.
  ///
  /// If [isRangeSelection] is enabled, the tap builds a range; otherwise,
  /// a single date is picked and the [_onUserPickedCallback] is fired.
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

      if (_rangeStart != null && _rangeEnd != null) {
        _onUserPickedCallback?.call(_getSelectedRangeDates());
      }
    } else {
      _userPicked = index;
      _onUserPickedCallback?.call([_getDateFromIndex(index)]);
    }

    notifyListeners();
  }

  /// Returns true if the given day [index] is within the user-selected range.
  bool isInRange(int index) {
    if (_rangeStart != null && _rangeEnd != null) {
      return index >= _rangeStart! && index <= _rangeEnd!;
    }
    return false;
  }

  /// Switches the calendar between range and single selection mode.
  ///
  /// Resets any current selections.
  void toggleSelectionMode(bool selectionMode) {
    isRangeSelection = selectionMode;
    _userPicked = null;
    _rangeStart = null;
    _rangeEnd = null;
    notifyListeners();
  }

  /// Converts a calendar cell [index] (1-based day of month) into a full [DateTime].
  DateTime _getDateFromIndex(int index) {
    return DateTime(_selectedMonth.year, _selectedMonth.month, index);
  }

  /// Generates a list of [DateTime]s within the user-selected range.
  ///
  /// Returns an empty list if the range is invalid.
  List<DateTime> _getSelectedRangeDates() {
    if (_rangeStart == null || _rangeEnd == null) return [];
    return List.generate(
      _rangeEnd! - _rangeStart! + 1,
      (i) => _getDateFromIndex(_rangeStart! + i),
    );
  }
}

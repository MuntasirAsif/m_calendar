import 'package:flutter/material.dart';
import '../model/marked_date_model.dart';

/// A [ChangeNotifier] that manages calendar state, including selected month,
/// selected dates, and range selection.
///
/// Used to control and update a custom calendar widget.
class MonthlyCalendarTableProvider extends ChangeNotifier {
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

  /// Earliest selectable date. Dates before this are disabled.
  DateTime? minDate;

  /// Latest selectable date. Dates after this are disabled.
  DateTime? maxDate;

  /// Predicate returning `true` if a given [DateTime] should be disabled.
  bool Function(DateTime date)? isDateDisabled;

  /// The currently selected dates (single date or full range).
  List<DateTime> get selectedDates {
    if (isRangeSelection) {
      return _getSelectedRangeDates();
    } else if (_userPicked != null) {
      return [_getDateFromIndex(_userPicked!)];
    }
    return const [];
  }

  /// Returns `true` if the day [dayNumber] of the selected month is disabled.
  bool isDayDisabled(int dayNumber) {
    final date = _getDateFromIndex(dayNumber);
    if (minDate != null) {
      final min = DateTime(minDate!.year, minDate!.month, minDate!.day);
      if (date.isBefore(min)) return true;
    }
    if (maxDate != null) {
      final max = DateTime(maxDate!.year, maxDate!.month, maxDate!.day);
      if (date.isAfter(max)) return true;
    }
    if (isDateDisabled != null && isDateDisabled!(date)) {
      return true;
    }
    return false;
  }

  /// Initializes the calendar with a specific [selectedMonth], optional marked days [customList],
  /// and a selection mode flag [isRange]. Also registers an optional [onUserPicked] callback
  /// and date disabling rules.
  void initializeMonth(
    DateTime selectedMonth,
    List<MarkedDaysModel>? customList,
    bool isRange, {
    void Function(List<DateTime>)? onUserPicked,
    DateTime? minDate,
    DateTime? maxDate,
    bool Function(DateTime date)? isDateDisabled,
  }) {
    // Normalize: only year and month are relevant for a month view.
    _selectedMonth = DateTime(selectedMonth.year, selectedMonth.month);
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month);
    _startOffset = (firstDay.weekday % 7);
    _totalDays = DateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    isRangeSelection = isRange;
    _onUserPickedCallback = onUserPicked;
    selectedDaysList = customList ?? [];
    this.minDate = minDate;
    this.maxDate = maxDate;
    this.isDateDisabled = isDateDisabled;

    _userPicked = null;
    _rangeStart = null;
    _rangeEnd = null;
    notifyListeners();
  }

  /// Programmatically changes the displayed month without resetting callbacks.
  void setMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month);
    _startOffset = (firstDay.weekday % 7);
    _totalDays = DateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    _userPicked = null;
    _rangeStart = null;
    _rangeEnd = null;
    notifyListeners();
  }

  /// Programmatically selects a [date] within the currently displayed month.
  void selectDate(DateTime date) {
    if (date.year == _selectedMonth.year &&
        date.month == _selectedMonth.month) {
      if (!isDayDisabled(date.day)) {
        _userPicked = date.day;
        _onUserPickedCallback?.call([date]);
        notifyListeners();
      }
    }
  }

  /// Programmatically selects a range between [start] and [end] within the currently displayed month.
  void selectRange(DateTime start, DateTime end) {
    if (start.year == _selectedMonth.year &&
        start.month == _selectedMonth.month &&
        end.year == _selectedMonth.year &&
        end.month == _selectedMonth.month) {
      final s = start.day <= end.day ? start.day : end.day;
      final e = start.day <= end.day ? end.day : start.day;
      _rangeStart = s;
      _rangeEnd = e;
      _onUserPickedCallback?.call(_getSelectedRangeDates());
      notifyListeners();
    }
  }

  /// Clears the current user selection.
  void clearSelection() {
    _userPicked = null;
    _rangeStart = null;
    _rangeEnd = null;
    notifyListeners();
  }

  /// Toggles the selection state when a user taps a calendar day cell.
  ///
  /// If [isRangeSelection] is enabled, the tap builds a range; otherwise,
  /// a single date is picked and the [_onUserPickedCallback] is fired.
  /// Disabled days are ignored.
  void toggleUserPicked(int index) {
    if (isDayDisabled(index)) return;

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

/// Backward-compatible alias for the misspelled provider name.
///
/// Kept so existing code importing `MonthlyCalenderTableProvider` continues
/// to compile. It will be removed in a future major release.
@Deprecated(
  'Use MonthlyCalendarTableProvider instead. '
  'This alias will be removed in a future major release.',
)
typedef MonthlyCalenderTableProvider = MonthlyCalendarTableProvider;

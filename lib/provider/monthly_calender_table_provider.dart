import 'package:flutter/material.dart';
import '../model/marked_date_model.dart';
import 'weekly_calendar_table_provider.dart' show Day;

/// A [ChangeNotifier] that manages calendar state, including selected month,
/// selected dates, and range selection.
///
/// Used to control and update a custom calendar widget.
class MonthlyCalendarTableProvider extends ChangeNotifier {
  /// The starting day of the week for the monthly view (defaults to [Day.saturday]).
  Day startDay = Day.saturday;

  /// Ordered weekday labels matching the configured [startDay].
  List<String> get weekNameList {
    const allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final startIndex = switch (startDay) {
      Day.monday => 0,
      Day.tuesday => 1,
      Day.wednesday => 2,
      Day.thursday => 3,
      Day.friday => 4,
      Day.saturday => 5,
      Day.sunday => 6,
    };
    return [...allDays.sublist(startIndex), ...allDays.sublist(0, startIndex)];
  }

  /// Calculates the leading blank cells for a month given its first day and start day.
  static int calculateStartOffset(DateTime firstDay, Day startDay) {
    final startWeekday = switch (startDay) {
      Day.monday => 1,
      Day.tuesday => 2,
      Day.wednesday => 3,
      Day.thursday => 4,
      Day.friday => 5,
      Day.saturday => 6,
      Day.sunday => 7,
    };
    return (firstDay.weekday - startWeekday + 7) % 7;
  }

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
  /// and a selection mode flag [isRange]. Also registers an optional [onUserPicked] callback,
  /// date disabling rules, and week [startDay].
  void initializeMonth(
    DateTime selectedMonth,
    List<MarkedDaysModel>? customList,
    bool isRange, {
    void Function(List<DateTime>)? onUserPicked,
    DateTime? minDate,
    DateTime? maxDate,
    bool Function(DateTime date)? isDateDisabled,
    Day startDay = Day.saturday,
    bool notify = true,
  }) {
    this.startDay = startDay;
    // Normalize: only year and month are relevant for a month view.
    _selectedMonth = DateTime(selectedMonth.year, selectedMonth.month);
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month);
    _startOffset = calculateStartOffset(firstDay, startDay);
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
    if (notify) notifyListeners();
  }

  /// Programmatically changes the displayed month without resetting callbacks.
  void setMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month);
    _startOffset = calculateStartOffset(firstDay, startDay);
    _totalDays = DateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    _userPicked = null;
    _rangeStart = null;
    _rangeEnd = null;
    notifyListeners();
  }

  /// Programmatically selects a [date], automatically switching months if needed.
  ///
  /// The time component of [date] is ignored. Dart normalizes out-of-range
  /// arguments (e.g. February 30 resolves to March 1), so the resulting
  /// canonical date is selected. Disabled dates are ignored.
  void selectDate(DateTime date) {
    final target = _dateOnly(date);
    if (target.year != _selectedMonth.year ||
        target.month != _selectedMonth.month) {
      setMonth(target);
    }
    if (!isDayDisabled(target.day)) {
      _userPicked = target.day;
      _onUserPickedCallback?.call([_getDateFromIndex(target.day)]);
      notifyListeners();
    }
  }

  /// Programmatically selects a range between [start] and [end], automatically
  /// switching months if needed.
  ///
  /// Both are normalized to date-only values and the shorter end is never
  /// assumed: the range is always sorted. The selection and the [onUserPicked]
  /// callback are confined to the month of the earlier date; if [end] falls in
  /// a later month the range is truncated to the end of [start]'s month.
  /// Out-of-range arguments are normalized by Dart (e.g. February 30 becomes
  /// March 1).
  void selectRange(DateTime start, DateTime end) {
    final s = _dateOnly(start);
    final e = _dateOnly(end);
    final earlier = s.isBefore(e) ? s : e;
    final later = s.isBefore(e) ? e : s;
    final sameMonth =
        later.year == earlier.year && later.month == earlier.month;
    if (sameMonth) {
      if (earlier.year != _selectedMonth.year ||
          earlier.month != _selectedMonth.month) {
        setMonth(earlier);
      }
      _rangeStart = earlier.day;
      _rangeEnd = later.day;
    } else {
      // Cross-month ranges highlight up to the end of the start month.
      if (earlier.year != _selectedMonth.year ||
          earlier.month != _selectedMonth.month) {
        setMonth(earlier);
      }
      _rangeStart = earlier.day;
      _rangeEnd = DateUtils.getDaysInMonth(earlier.year, earlier.month);
    }
    _onUserPickedCallback?.call(_getSelectedRangeDates());
    notifyListeners();
  }

  /// Updates the disabling rules, marked days, and pick callback without
  /// resetting the current selection.
  ///
  /// Contrast this with [initializeMonth]/[setMonth], which clear any existing
  /// selection. Passing `null` clears the respective disabling rule.
  void updateConfiguration({
    DateTime? minDate,
    DateTime? maxDate,
    bool Function(DateTime date)? isDateDisabled,
    List<MarkedDaysModel>? markedDaysList,
    bool notify = true,
  }) {
    var changed = false;
    if (this.minDate != minDate) {
      this.minDate = minDate;
      changed = true;
    }
    if (this.maxDate != maxDate) {
      this.maxDate = maxDate;
      changed = true;
    }
    if (this.isDateDisabled != isDateDisabled) {
      this.isDateDisabled = isDateDisabled;
      changed = true;
    }
    if (markedDaysList != null &&
        !identical(selectedDaysList, markedDaysList)) {
      selectedDaysList = markedDaysList;
      changed = true;
    }
    if (changed && notify) notifyListeners();
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

  /// Returns a date-only copy of [date] (time components removed).
  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

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

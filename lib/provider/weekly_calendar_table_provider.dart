import 'package:flutter/material.dart';
import '../model/marked_date_model.dart';

/// Enum representing the days of the week.
enum Day {
  /// Indicate start day is monday
  monday,

  /// Indicate start day is tuesday
  tuesday,

  /// Indicate start day is wednesday
  wednesday,

  /// Indicate start day is thursday
  thursday,

  /// Indicate start day is friday
  friday,

  /// Indicate start day is saturday
  saturday,

  /// Indicate start day is sunday
  sunday,
}

/// A provider that handles weekly calendar logic, including month initialization,
/// range selection, and week generation.
class WeeklyCalendarTableProvider extends ChangeNotifier {
  /// The currently selected month.
  late DateTime _selectedMonth;

  /// Total number of days in the selected month.
  late int _totalDays;

  /// The number of days to offset the first day of the month.
  late int _startOffset;

  /// The starting day of the week for the calendar (used to customize week layout).
  late Day startedDay;

  /// The date selected by the user (used for range selection).
  DateTime? _userPicked;

  /// Flag indicating whether range selection is enabled.
  bool isRangeSelection = false;

  /// List of custom marked dates.
  List<MarkedDaysModel> selectedDaysList = [];

  /// Callback function that is invoked when the user picks a date.
  void Function(List<DateTime>)? _onUserPickedCallback;

  /// Cached weeks-per-month map, recomputed on [initializeMonth].
  Map<String, List<List<DateTime>>> _monthWeekMap = {};

  /// The maximum number of week rows any displayed month needs (5 or 6).
  int _maxWeekCount = 5;

  /// Getter for the selected month.
  DateTime get selectedMonth => _selectedMonth;

  /// Getter for the total number of days in the selected month.
  int get totalDays => _totalDays;

  /// Getter for the start offset (number of days to offset the first day of the month).
  int get startOffset => _startOffset;

  /// Getter for the user-picked date.
  DateTime? get userPicked => _userPicked;

  /// A map representing weeks for each month, where each week starts from the selected start day.
  Map<String, List<List<DateTime>>> get monthWeekMap => _monthWeekMap;

  /// The maximum number of week rows needed by any displayed month.
  ///
  /// Most months fit in 5 rows, but depending on [startedDay] some months
  /// require 6. Use this to build a consistent number of columns.
  int get maxWeekCount => _maxWeekCount;

  /// Initializes the month and other settings for the calendar.
  ///
  /// Takes the selected month, start day, a list of custom marked dates, and a flag for range selection.
  /// Also, an optional callback is provided to handle user-picked dates.
  void initializeMonth(
    DateTime selectedMonth,
    Day startDay,
    List<MarkedDaysModel>? customList,
    bool isRange, {
    void Function(List<DateTime>)? onUserPicked,
  }) {
    // Normalize: only year and month are relevant for a month view.
    _selectedMonth = DateTime(selectedMonth.year, selectedMonth.month);
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month);
    startedDay = startDay;
    _startOffset = (firstDay.weekday % 7);
    _totalDays = DateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    isRangeSelection = isRange;
    _onUserPickedCallback = onUserPicked;
    selectedDaysList = customList ?? [];
    _userPicked = null;
    _monthWeekMap = _generateWeeksByMonth();
    notifyListeners();
  }

  /// Toggles the user-picked date.
  ///
  /// When a user selects a date, this method is called to update the selected date.
  /// It also calls the callback with the picked date to notify listeners of the change.
  void toggleUserPicked(DateTime date) {
    _userPicked = date;

    // If the callback exists, call it with the picked date wrapped in a List
    if (_onUserPickedCallback != null) {
      _onUserPickedCallback!([date]); // Pass the date as a list
    }

    notifyListeners();
  }

  /// Updates the displayed month and re-computes the 6-month table window.
  void setSelectedMonth(DateTime month) {
    initializeMonth(
      month,
      startedDay,
      selectedDaysList,
      isRangeSelection,
      onUserPicked: _onUserPickedCallback,
    );
  }

  /// Clears the current user selection.
  void clearSelection() {
    _userPicked = null;
    notifyListeners();
  }

  /// Generates weeks for the selected month (and the 5 preceding months)
  /// based on the configured [startedDay].
  Map<String, List<List<DateTime>>> _generateWeeksByMonth() {
    final Map<String, List<List<DateTime>>> result = {};

    for (int m = 5; m >= 0; m--) {
      final current = DateTime(_selectedMonth.year, _selectedMonth.month - m);
      final label = _monthName(current.month);
      final daysInMonth = DateUtils.getDaysInMonth(current.year, current.month);

      final List<List<DateTime>> weeks = [];
      List<DateTime> currentWeek = [];

      for (int i = 1; i <= daysInMonth; i++) {
        final day = DateTime(current.year, current.month, i);
        currentWeek.add(day);

        // Close the week at the configured week end or at month end.
        if (day.weekday == _getWeekEnd() || i == daysInMonth) {
          weeks.add(List.of(currentWeek));
          currentWeek = [];
        }
      }

      // Fill blank week cells if the month uses fewer than 5 rows.
      while (weeks.length < 5) {
        weeks.add([]);
      }

      result[label] = weeks;
    }

    // Some months need a 6th row depending on the week start day.
    _maxWeekCount = 5;
    for (final weeks in result.values) {
      if (weeks.length > _maxWeekCount) _maxWeekCount = weeks.length;
    }

    // Pad every month to the same row count so table rows stay aligned.
    for (final entry in result.entries) {
      while (entry.value.length < _maxWeekCount) {
        entry.value.add([]);
      }
    }

    return result;
  }

  /// Determines the end day of the week based on the selected start day.
  int _getWeekEnd() {
    final start = switch (startedDay) {
      Day.monday => DateTime.monday,
      Day.tuesday => DateTime.tuesday,
      Day.wednesday => DateTime.wednesday,
      Day.thursday => DateTime.thursday,
      Day.friday => DateTime.friday,
      Day.saturday => DateTime.saturday,
      Day.sunday => DateTime.sunday,
    };
    // The week ends one day before the start day (wrapping 7 → 1).
    // A Sunday-starting week ends on Saturday; a Monday-starting week ends
    // on Sunday (weekday 7). Anything else ends on `start - 1`.
    return start == DateTime.monday ? DateTime.sunday : start - 1;
  }

  /// Converts a numerical month value to its string abbreviation (e.g., 1 -> 'JAN').
  String _monthName(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }

  /// Converts a month abbreviation (e.g., 'JAN') to its numerical value (e.g., 1).
  int monthNameToNumber(String label) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months.indexOf(label) + 1;
  }
}

/// Backward-compatible alias for the misspelled provider name.
///
/// Kept so existing code importing `WeeklyCalenderTableProvider` continues
/// to compile. It will be removed in a future major release.
@Deprecated(
  'Use WeeklyCalendarTableProvider instead. '
  'This alias will be removed in a future major release.',
)
typedef WeeklyCalenderTableProvider = WeeklyCalendarTableProvider;

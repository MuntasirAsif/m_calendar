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
class WeeklyCalenderTableProvider extends ChangeNotifier {
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

  /// Getter for the selected month.
  DateTime get selectedMonth => _selectedMonth;

  /// Getter for the total number of days in the selected month.
  int get totalDays => _totalDays;

  /// Getter for the start offset (number of days to offset the first day of the month).
  int get startOffset => _startOffset;

  /// Getter for the user-picked date.
  DateTime? get userPicked => _userPicked;

  /// A map representing weeks for each month, where each week starts from the selected start day.
  Map<String, List<List<DateTime>>> get monthWeekMap => _generateWeeksByMonth();

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
    _selectedMonth = selectedMonth;
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    startedDay = startDay;
    _startOffset = (firstDay.weekday % 7);
    _totalDays = DateUtils.getDaysInMonth(
      selectedMonth.year,
      selectedMonth.month,
    );
    isRangeSelection = isRange;
    _onUserPickedCallback = onUserPicked;
    selectedDaysList = customList ?? [];
    _userPicked = null;
    notifyListeners();
  }

  /// Toggles the user-picked date.
  ///
  /// When a user selects a date, this method is called to update the selected date.
  /// It also calls the callback with the picked date to notify listeners of the change.
  void toggleUserPicked(DateTime date) {
    _userPicked = date;
    debugPrint('Picked date: ${date.toString()}');

    // If the callback exists, call it with the picked date wrapped in a List
    if (_onUserPickedCallback != null) {
      _onUserPickedCallback!([date]); // Pass the date as a list
    }

    notifyListeners();
  }

  /// Generates weeks for the selected month based on the starting day of the week.
  ///
  /// The calendar layout considers that the week starts from the `startedDay` and ends on the last day.
  /// It supports weeks with up to 5 rows, filling empty weeks if necessary.
  Map<String, List<List<DateTime>>> _generateWeeksByMonth() {
    final Map<String, List<List<DateTime>>> result = {};

    for (int m = 5; m >= 0; m--) {
      final current = DateTime(_selectedMonth.year, _selectedMonth.month - m);
      final label = _monthName(current.month);
      final daysInMonth = DateUtils.getDaysInMonth(current.year, current.month);

      List<List<DateTime>> weeks = [];
      List<DateTime> currentWeek = [];

      for (int i = 1; i <= daysInMonth; i++) {
        final day = DateTime(current.year, current.month, i);
        currentWeek.add(day);

        // Add week when it's Friday or last date
        if (day.weekday == _getWeekEnd() || i == daysInMonth) {
          weeks.add(currentWeek);
          currentWeek = [];
        }
      }

      // 🟡 Fill blank week cells if weeks < 5
      while (weeks.length < 5) {
        weeks.add([]); // blank week
      }

      // 🛑 Strict: Never allow more than 5 weeks
      if (weeks.length > 5) {
        // if 6th week exists but has no real day, discard
        if (weeks[5].isEmpty) {
          weeks.removeLast();
        } else {
          // If accidentally went over due to a Friday being early,
          // just merge extra into week 5 if needed or trim
          weeks = weeks.sublist(0, 5);
        }
      }

      result[label] = weeks;
    }

    return result;
  }

  /// Determines the end day of the week based on the selected start day.
  ///
  /// The end day is determined by the `startedDay`, which adjusts the week ending day accordingly.
  int _getWeekEnd() {
    if (startedDay == Day.saturday) {
      return DateTime.friday;
    } else if (startedDay == Day.sunday) {
      return DateTime.saturday;
    } else if (startedDay == Day.monday) {
      return DateTime.sunday;
    } else if (startedDay == Day.tuesday) {
      return DateTime.monday;
    } else if (startedDay == Day.wednesday) {
      return DateTime.tuesday;
    } else if (startedDay == Day.thursday) {
      return DateTime.wednesday;
    } else if (startedDay == Day.friday) {
      return DateTime.thursday;
    } else {
      return DateTime.friday;
    }
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

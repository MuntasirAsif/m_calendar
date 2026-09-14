import 'package:flutter/material.dart';
import '../provider/monthly_calender_table_provider.dart';

/// An imperative controller for an [MCalendar] instance.
///
/// Use an [MCalendarController] to programmatically change the displayed month,
/// navigate forward or backward, select dates or ranges, and query the current
/// selection.
///
/// ```dart
/// final controller = MCalendarController();
///
/// // In your widget:
/// MCalendar(
///   controller: controller,
///   selectedMonth: DateTime(2026, 3),
///   onUserPicked: (dates) => print(dates),
/// )
///
/// // Later:
/// controller.nextMonth();
/// controller.selectDate(DateTime(2026, 3, 20));
/// ```
class MCalendarController extends ChangeNotifier {
  /// Creates an [MCalendarController] optionally initialized to [initialMonth].
  MCalendarController({DateTime? initialMonth})
    : _displayedMonth =
          initialMonth != null
              ? DateTime(initialMonth.year, initialMonth.month)
              : null;

  DateTime? _displayedMonth;
  MonthlyCalendarTableProvider? _provider;

  /// The optional initial month provided at construction.
  DateTime? get initialMonth => _displayedMonth;

  /// The currently displayed month (normalized to year and month only).
  DateTime get displayedMonth =>
      _provider?.selectedMonth ??
      _displayedMonth ??
      DateTime(DateTime.now().year, DateTime.now().month);

  /// The currently selected dates, if any.
  ///
  /// Returns a single-item list for single-date selection, all dates in the
  /// range for range selection, or an empty list if nothing is selected.
  List<DateTime> get selectedDates => _provider?.selectedDates ?? const [];

  /// Programmatically changes the displayed month and notifies listeners.
  void setMonth(DateTime month) {
    _displayedMonth = DateTime(month.year, month.month);
    _provider?.setMonth(_displayedMonth!);
    notifyListeners();
  }

  /// Advances the calendar by one month.
  void nextMonth() {
    final current = displayedMonth;
    setMonth(DateTime(current.year, current.month + 1));
  }

  /// Moves the calendar back by one month.
  void previousMonth() {
    final current = displayedMonth;
    setMonth(DateTime(current.year, current.month - 1));
  }

  /// Programmatically selects a single [date] in the currently displayed month.
  void selectDate(DateTime date) {
    _provider?.selectDate(date);
  }

  /// Programmatically selects a range between [start] and [end].
  void selectRange(DateTime start, DateTime end) {
    _provider?.selectRange(start, end);
  }

  /// Clears the current selection.
  void clearSelection() {
    _provider?.clearSelection();
  }

  /// Attaches a [MonthlyCalendarTableProvider] to this controller.
  ///
  /// Internal use only.
  void attach(MonthlyCalendarTableProvider provider) {
    _provider = provider;
    if (_displayedMonth != null) {
      _provider?.setMonth(_displayedMonth!);
    }
  }

  /// Detaches the currently attached provider.
  ///
  /// Internal use only.
  void detach() {
    _provider = null;
  }
}

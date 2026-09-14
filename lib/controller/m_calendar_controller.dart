import 'package:flutter/material.dart';
import '../provider/horizontal_calendar_provider.dart';
import '../provider/monthly_calender_table_provider.dart';
import '../provider/weekly_calendar_table_provider.dart';

/// An imperative controller for an [MCalendar] instance.
///
/// Use an [MCalendarController] to programmatically change the displayed month,
/// navigate forward or backward, select dates or ranges, and query the current
/// selection. Works across monthly, weekly, and horizontal calendar layouts.
///
/// Listeners added to [MCalendarController] are automatically notified whenever
/// the user interacts with the calendar or when programmatic changes occur.
///
/// ```dart
/// final controller = MCalendarController();
///
/// controller.addListener(() {
///   print('Selected: ${controller.selectedDates}');
/// });
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
  MonthlyCalendarTableProvider? _monthlyProvider;
  WeeklyCalendarTableProvider? _weeklyProvider;
  HorizontalCalendarProvider? _horizontalProvider;

  /// The optional initial month provided at construction.
  DateTime? get initialMonth => _displayedMonth;

  /// The currently displayed month (normalized to year and month only).
  DateTime get displayedMonth =>
      _monthlyProvider?.selectedMonth ??
      _weeklyProvider?.selectedMonth ??
      _horizontalProvider?.selectedMonth ??
      _displayedMonth ??
      DateTime(DateTime.now().year, DateTime.now().month);

  /// The currently selected dates, if any.
  ///
  /// Returns a single-item list for single-date selection, all dates in the
  /// range for range selection, or an empty list if nothing is selected.
  List<DateTime> get selectedDates {
    if (_monthlyProvider != null) {
      return _monthlyProvider!.selectedDates;
    }
    if (_weeklyProvider != null && _weeklyProvider!.userPicked != null) {
      return [_weeklyProvider!.userPicked!];
    }
    if (_horizontalProvider != null &&
        _horizontalProvider!.selectedDay.year != 0) {
      return [_horizontalProvider!.selectedDay];
    }
    return const [];
  }

  /// Programmatically changes the displayed month and notifies listeners.
  void setMonth(DateTime month) {
    _displayedMonth = DateTime(month.year, month.month);
    _monthlyProvider?.setMonth(_displayedMonth!);
    _weeklyProvider?.setSelectedMonth(_displayedMonth!);
    _horizontalProvider?.setSelectedMonth(_displayedMonth!);
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

  /// Programmatically selects a single [date].
  void selectDate(DateTime date) {
    _monthlyProvider?.selectDate(date);
    _weeklyProvider?.toggleUserPicked(date);
    _horizontalProvider?.setSelectedDay(date);
  }

  /// Programmatically selects a range between [start] and [end].
  void selectRange(DateTime start, DateTime end) {
    _monthlyProvider?.selectRange(start, end);
  }

  /// Clears the current selection.
  void clearSelection() {
    _monthlyProvider?.clearSelection();
    _weeklyProvider?.clearSelection();
    _horizontalProvider?.clearSelection();
    notifyListeners();
  }

  void _onProviderNotify() {
    // Keep the fallback month in sync with the attached provider so a later
    // detach (or a provider-driven header navigation) doesn't resurrect a
    // stale displayed month.
    final providerMonth =
        _monthlyProvider?.selectedMonth ??
        _weeklyProvider?.selectedMonth ??
        _horizontalProvider?.selectedMonth;
    if (providerMonth != null &&
        (providerMonth.year != _displayedMonth?.year ||
            providerMonth.month != _displayedMonth?.month)) {
      _displayedMonth = DateTime(providerMonth.year, providerMonth.month);
    }
    notifyListeners();
  }

  /// Attaches a provider to this controller.
  ///
  /// Automatically listens to provider changes so registered listeners on this
  /// controller receive notifications when the user picks dates or changes months.
  ///
  /// Internal use only.
  void attach(Object provider) {
    if (provider is MonthlyCalendarTableProvider) {
      if (_monthlyProvider == provider) return;
      _monthlyProvider?.removeListener(_onProviderNotify);
      _monthlyProvider = provider;
      _monthlyProvider?.addListener(_onProviderNotify);
      if (_displayedMonth != null) {
        _monthlyProvider?.setMonth(_displayedMonth!);
      }
    } else if (provider is WeeklyCalendarTableProvider) {
      if (_weeklyProvider == provider) return;
      _weeklyProvider?.removeListener(_onProviderNotify);
      _weeklyProvider = provider;
      _weeklyProvider?.addListener(_onProviderNotify);
      if (_displayedMonth != null) {
        _weeklyProvider?.setSelectedMonth(_displayedMonth!);
      }
    } else if (provider is HorizontalCalendarProvider) {
      if (_horizontalProvider == provider) return;
      _horizontalProvider?.removeListener(_onProviderNotify);
      _horizontalProvider = provider;
      _horizontalProvider?.addListener(_onProviderNotify);
      if (_displayedMonth != null) {
        _horizontalProvider?.setSelectedMonth(_displayedMonth!);
      }
    }
  }

  /// Detaches all currently attached providers.
  ///
  /// Internal use only.
  void detach() {
    _monthlyProvider?.removeListener(_onProviderNotify);
    _weeklyProvider?.removeListener(_onProviderNotify);
    _horizontalProvider?.removeListener(_onProviderNotify);
    _monthlyProvider = null;
    _weeklyProvider = null;
    _horizontalProvider = null;
  }

  @override
  void dispose() {
    detach();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:m_calendar/view/calendar_header_view.dart';
import 'package:provider/provider.dart';

import '../controller/m_calendar_controller.dart';
import '../model/day_state.dart';
import '../model/marked_date_model.dart';
import '../provider/monthly_calender_table_provider.dart';
import '../provider/weekly_calendar_table_provider.dart' show Day;
import '../widgets/calendar_date_cell.dart';

/// A widget that displays the monthly calendar view, showing the days of a month
/// and allowing the user to select dates.
///
/// Supports single date selection, range selection, marked dates, custom day
/// builders, date disabling (via [minDate], [maxDate], or [isDateDisabled]),
/// customizable week [startDay], and programmatic control via [MCalendarController].
class MonthlyView extends StatefulWidget {
  /// Constructs a [MonthlyView] widget.
  const MonthlyView({
    super.key,
    required this.selectedMonth,
    this.decoration,
    this.markedDaysList,
    this.weekNameHeaderStyle,
    this.defaultChild,
    this.userPickedDecoration,
    this.userPickedChild,
    this.cellPadding,
    required this.onUserPicked,
    required this.showMonthYearPicker,
    this.controller,
    this.dayBuilder,
    this.minDate,
    this.maxDate,
    this.isDateDisabled,
    this.disabledDecoration,
    this.disabledTextStyle,
    this.startDay = Day.saturday,
  });

  /// The currently selected month for the calendar.
  final DateTime selectedMonth;

  /// The decoration applied to the calendar container.
  final BoxDecoration? decoration;

  /// A list of custom marked days to highlight in the calendar.
  final List<MarkedDaysModel>? markedDaysList;

  /// The style applied to the week name header (e.g., "Mon", "Tue", "Wed", etc.).
  final TextStyle? weekNameHeaderStyle;

  /// The default widget to display inside each calendar date cell.
  final Widget? defaultChild;

  /// The decoration applied to user-selected dates.
  final BoxDecoration? userPickedDecoration;

  /// The widget displayed inside the cells of the user-selected dates.
  final Widget? userPickedChild;

  /// The padding around each calendar cell.
  final EdgeInsets? cellPadding;

  /// A callback triggered when the user selects a date or a range of dates.
  final void Function(List<DateTime>) onUserPicked;

  /// A flag indicating whether to show the month and year picker in the calendar header.
  final bool showMonthYearPicker;

  /// Optional controller to programmatically drive calendar navigation and selections.
  final MCalendarController? controller;

  /// Optional builder to customize rendering of each day cell.
  final CalendarDayBuilder? dayBuilder;

  /// Earliest date that can be selected. Earlier dates are disabled.
  final DateTime? minDate;

  /// Latest date that can be selected. Later dates are disabled.
  final DateTime? maxDate;

  /// Predicate returning `true` if a given [DateTime] should be disabled.
  final bool Function(DateTime date)? isDateDisabled;

  /// Custom decoration applied to disabled date cells.
  final BoxDecoration? disabledDecoration;

  /// Custom text style applied to disabled date numbers.
  final TextStyle? disabledTextStyle;

  /// Starting day of the week for column ordering. Defaults to [Day.saturday].
  final Day startDay;

  @override
  State<MonthlyView> createState() => _MonthlyViewState();
}

class _MonthlyViewState extends State<MonthlyView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<MonthlyCalendarTableProvider>(
      context,
      listen: false,
    );
    widget.controller?.attach(provider);
  }

  @override
  void didUpdateWidget(MonthlyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final provider = Provider.of<MonthlyCalendarTableProvider>(
      context,
      listen: false,
    );

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      widget.controller?.attach(provider);
    }

    final monthChanged =
        oldWidget.selectedMonth.year != widget.selectedMonth.year ||
        oldWidget.selectedMonth.month != widget.selectedMonth.month ||
        oldWidget.startDay != widget.startDay;

    if (monthChanged) {
      provider.initializeMonth(
        widget.selectedMonth,
        widget.markedDaysList ?? provider.selectedDaysList,
        provider.isRangeSelection,
        onUserPicked: widget.onUserPicked,
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        isDateDisabled: widget.isDateDisabled,
        startDay: widget.startDay,
        // The tree is already rebuilding; notifying synchronously while the
        // element tree is being updated is disallowed by the framework.
        notify: false,
      );
    } else if (oldWidget.minDate != widget.minDate ||
        oldWidget.maxDate != widget.maxDate ||
        oldWidget.isDateDisabled != widget.isDateDisabled ||
        oldWidget.markedDaysList != widget.markedDaysList) {
      // Propagate config changes without resetting the current selection.
      provider.updateConfiguration(
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        isDateDisabled: widget.isDateDisabled,
        markedDaysList: widget.markedDaysList,
        notify: false,
      );
    }
  }

  @override
  void dispose() {
    widget.controller?.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MonthlyCalendarTableProvider>(
      builder: (_, provider, __) {
        return Column(
          children: [
            if (widget.showMonthYearPicker)
              CalendarHeaderView(
                displayedMonth: provider.selectedMonth,
                onMonthChanged: (value) {
                  provider.initializeMonth(
                    value,
                    provider.selectedDaysList,
                    provider.isRangeSelection,
                    onUserPicked: widget.onUserPicked,
                    minDate: widget.minDate,
                    maxDate: widget.maxDate,
                    isDateDisabled: widget.isDateDisabled,
                    startDay: widget.startDay,
                  );
                },
              ),
            Table(
              children: [
                // Week header row (e.g., "Sat", "Sun", "Mon", etc.)
                TableRow(
                  children:
                      provider.weekNameList.map((name) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              name,
                              style:
                                  widget.weekNameHeaderStyle ??
                                  const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                // Rows representing the days of the month
                ..._generateCalendarRows(provider),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Generates rows for the calendar, breaking the days of the month into weeks.
  List<TableRow> _generateCalendarRows(MonthlyCalendarTableProvider provider) {
    final List<Widget> dayCells = [];

    // Fill empty days before the first of the month
    for (int i = 0; i < provider.startOffset; i++) {
      dayCells.add(const SizedBox.shrink());
    }

    // Add date cells for each day of the month
    for (int i = 1; i <= provider.totalDays; i++) {
      dayCells.add(
        CalendarDateCell(
          i: i,
          defaultDecoration: widget.decoration,
          defaultChild: widget.defaultChild,
          userPickedDecoration: widget.userPickedDecoration,
          userPickedChild: widget.userPickedChild,
          cellPadding: widget.cellPadding,
          dayBuilder: widget.dayBuilder,
          disabledDecoration: widget.disabledDecoration,
          disabledTextStyle: widget.disabledTextStyle,
        ),
      );
    }

    // Break day cells into 7-day groups (weeks)
    final List<TableRow> calendarRows = [];
    for (int i = 0; i < dayCells.length; i += 7) {
      final List<Widget> weekRow = dayCells.sublist(
        i,
        i + 7 > dayCells.length ? dayCells.length : i + 7,
      );

      // Pad remaining days in the last row to maintain 7 columns
      while (weekRow.length < 7) {
        weekRow.add(const SizedBox.shrink());
      }

      calendarRows.add(TableRow(children: weekRow));
    }

    return calendarRows;
  }
}

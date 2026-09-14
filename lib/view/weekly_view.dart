import 'package:flutter/material.dart';
import 'package:m_calendar/provider/weekly_calendar_table_provider.dart';
import 'package:m_calendar/widgets/calendar_week_cell.dart';
import 'package:provider/provider.dart';
import '../controller/m_calendar_controller.dart';
import '../model/calendar_animations.dart';
import '../model/marked_date_model.dart';
import '../widgets/animated_month_grid.dart';

/// A widget that displays the weekly calendar view, showing weeks of a month
/// with the ability to select individual dates.
///
/// This widget allows users to interact with the calendar to select a specific date
/// or range of dates (if enabled). The selected dates are passed back via the
/// `onUserPicked` callback.
///
/// Note: tapping a week reports a single picked date (the first day of the week)
/// via `onUserPicked`. The `isRangeSelection` flag is currently accepted for API
/// symmetry but weekly range selection is not implemented.
class WeeklyView extends StatefulWidget {
  /// Constructs a `WeeklyView` widget.
  const WeeklyView({
    super.key,
    required this.selectedMonth,
    required this.onUserPicked,
    this.markedDaysList,
    this.weekNameHeaderStyle,
    this.userPickedDecoration,
    this.userPickedChild,
    this.cellPadding,
    this.decoration,
    this.defaultChild,
    this.isRangeSelection = false,
    required this.startDay,
    this.controller,
    this.animations,
  });

  /// The currently selected month for the calendar.
  final DateTime selectedMonth;

  /// The decoration applied to the calendar container.
  final BoxDecoration? decoration;

  /// A list of custom marked days to highlight in the calendar.
  final List<MarkedDaysModel>? markedDaysList;

  /// The style applied to the week name header (e.g., "Week 1", "Week 2").
  final TextStyle? weekNameHeaderStyle;

  /// The default widget to display inside each week cell.
  final Widget? defaultChild;

  /// The decoration applied to user-selected dates.
  final BoxDecoration? userPickedDecoration;

  /// The widget displayed on the user-selected date cells.
  final Widget? userPickedChild;

  /// The padding around each cell in the calendar.
  final EdgeInsets? cellPadding;

  /// A callback triggered when the user selects a date or a range of dates.
  final void Function(List<DateTime>) onUserPicked;

  /// A flag indicating if range selection is enabled (default is `false`).
  final bool isRangeSelection;

  /// The starting day of the week (default is `Day.saturday`).
  final Day startDay;

  /// Optional controller to programmatically drive calendar navigation and selections.
  final MCalendarController? controller;

  /// Optional animation configuration. When `null` (the default) every update
  /// is instant.
  final CalendarAnimations? animations;

  @override
  State<WeeklyView> createState() => _WeeklyViewState();
}

class _WeeklyViewState extends State<WeeklyView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<WeeklyCalendarTableProvider>(
      context,
      listen: false,
    );
    widget.controller?.attach(provider);
  }

  @override
  void didUpdateWidget(WeeklyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final provider = Provider.of<WeeklyCalendarTableProvider>(
      context,
      listen: false,
    );

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      widget.controller?.attach(provider);
    }

    if (oldWidget.selectedMonth.year != widget.selectedMonth.year ||
        oldWidget.selectedMonth.month != widget.selectedMonth.month ||
        oldWidget.startDay != widget.startDay) {
      provider.initializeMonth(
        widget.selectedMonth,
        widget.startDay,
        widget.markedDaysList ?? provider.selectedDaysList,
        widget.isRangeSelection,
        onUserPicked: widget.onUserPicked,
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
    return Consumer<WeeklyCalendarTableProvider>(
      builder: (context, provider, __) {
        final monthWeekMap = provider.monthWeekMap;
        final months = monthWeekMap.keys.toList();
        final weekCount = provider.maxWeekCount;
        final selectionDuration = CalendarAnimations.selectionOf(
          context,
          widget.animations,
        );
        final selectionCurve =
            widget.animations?.selectionCurve ?? Curves.easeOut;
        final monthDuration = CalendarAnimations.monthTransitionOf(
          context,
          widget.animations,
        );
        final monthCurve =
            widget.animations?.monthTransitionCurve ?? Curves.easeOutCubic;
        final sizeDuration = CalendarAnimations.sizeOf(
          context,
          widget.animations,
        );

        final grid = Table(
          columnWidths: const {
            0: FixedColumnWidth(60), // Fixed width for month labels
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // WEEK HEADER ROW
            TableRow(
              children: [
                const SizedBox.shrink(),
                ...List.generate(weekCount, (index) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Week ${index + 1}',
                        style:
                            widget.weekNameHeaderStyle ??
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
              ],
            ),

            // CALENDAR ROWS FOR EACH MONTH
            for (int i = 0; i < months.length; i++)
              TableRow(
                children: [
                  // Month Name Cell
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      months[i],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Weeks for this month
                  ...List.generate(weekCount, (weekIndex) {
                    final weeks = monthWeekMap[months[i]]!;

                    if (weekIndex < weeks.length &&
                        weeks[weekIndex].isNotEmpty) {
                      final week = weeks[weekIndex];
                      final firstDate = week.first;
                      final lastDate = week.last;

                      final isSelected =
                          provider.userPicked != null &&
                          provider.userPicked!.year == firstDate.year &&
                          provider.userPicked!.month == firstDate.month &&
                          provider.userPicked!.isAfter(
                            firstDate.subtract(const Duration(days: 1)),
                          ) &&
                          provider.userPicked!.isBefore(
                            lastDate.add(const Duration(days: 1)),
                          );

                      return WeeklyCalendarDateCell(
                        firstDate: firstDate,
                        lastDate: lastDate,
                        isSelected: isSelected,
                        onTap: () => provider.toggleUserPicked(firstDate),
                        defaultDecoration: widget.decoration,
                        defaultChild: widget.defaultChild,
                        userPickedDecoration: widget.userPickedDecoration,
                        userPickedChild: widget.userPickedChild,
                        cellPadding: widget.cellPadding,
                        animationDuration: selectionDuration,
                        animationCurve: selectionCurve,
                      );
                    } else {
                      // Blank placeholder cell
                      return const WeeklyCalendarDateCell(
                        firstDate: _emptyDate,
                        lastDate: _emptyDate,
                        isSelected: false,
                      );
                    }
                  }),
                ],
              ),
          ],
        );

        return AnimatedMonthGrid(
          month: provider.selectedMonth,
          duration: monthDuration,
          curve: monthCurve,
          sizeDuration: sizeDuration,
          child: grid,
        );
      },
    );
  }
}

/// Constant empty date used as placeholder for blank cells.
const DateTime _emptyDate = _StaticDate(0);

class _StaticDate implements DateTime {
  const _StaticDate(this.year);

  @override
  final int year;

  @override
  int get month => 0;

  @override
  int get day => 0;

  @override
  int get hour => 0;

  @override
  int get minute => 0;

  @override
  int get second => 0;

  @override
  int get millisecond => 0;

  @override
  int get microsecond => 0;

  @override
  int get weekday => 0;

  @override
  bool get isUtc => false;

  @override
  DateTime add(Duration duration) => this;

  @override
  DateTime subtract(Duration duration) => this;

  @override
  Duration difference(DateTime other) => Duration.zero;

  @override
  int compareTo(DateTime other) => 0;

  @override
  bool isAfter(DateTime other) => false;

  @override
  bool isBefore(DateTime other) => false;

  @override
  bool isAtSameMomentAs(DateTime other) => false;

  @override
  DateTime toLocal() => this;

  @override
  DateTime toUtc() => this;

  @override
  String toIso8601String() => '';

  @override
  String get timeZoneName => '';

  @override
  Duration get timeZoneOffset => Duration.zero;

  @override
  int get millisecondsSinceEpoch => 0;

  @override
  int get microsecondsSinceEpoch => 0;
}

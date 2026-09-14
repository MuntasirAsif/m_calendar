import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m_calendar/provider/horizontal_calendar_provider.dart';
import 'package:m_calendar/view/calendar_header_view.dart';
import 'package:provider/provider.dart';

import '../controller/m_calendar_controller.dart';

/// Horizontal scrolling calendar view.
///
/// Shows dates of the selected month horizontally with single-date selection
/// and optional custom decorations for default, marked, and selected states.
class HorizontalView extends StatefulWidget {
  /// Default factory constructor with pre-configured decorations.
  factory HorizontalView.defaults({
    required DateTime selectedMonth,
    required void Function(DateTime) onUserPicked,
    bool showWeekDays = true,
    TextStyle? dateTextStyle,
    TextStyle? weekDaysTextStyle,
    TextStyle? selectedDateTextStyle,
    TextStyle? selectedWeekDaysTextStyle,
    DateTime? initialDate,
    DateTime? endDate,
    MCalendarController? controller,
  }) {
    return HorizontalView(
      selectedMonth: selectedMonth,
      onUserPicked: onUserPicked,
      showWeekDays: showWeekDays,
      dateTextStyle: dateTextStyle,
      weekDaysTextStyle: weekDaysTextStyle,
      selectedDateTextStyle: selectedDateTextStyle,
      selectedWeekDaysTextStyle: selectedWeekDaysTextStyle,
      initialDate: initialDate,
      endDate: endDate,
      controller: controller,
    );
  }

  /// Creates a new instance of the [HorizontalView] widget.
  ///
  /// [showMonthYearPicker] controls whether the month/year picker header is
  /// shown. [initialDate] (optional) determines where the list will auto-scroll
  /// on first build when [autoScroll] is true, and acts as the lower date bound.
  const HorizontalView({
    super.key,
    this.decoration,
    this.userPickedDecoration,
    this.defaultChild,
    this.userPickedChild,
    this.showMonthYearPicker = false,
    this.headerTextStyle,
    this.headerIconColor,
    this.headerHeight,
    this.monthYearPickerSelectedMonthColor,
    this.monthYearPickerUnselectedMonthColor,
    this.monthYearPickerCrossAxisCount,
    this.monthYearPickerChildAspectRatio,
    this.monthYearPickerMonthItemDecoration,
    this.showWeekDays = true,
    this.dateTextStyle,
    this.weekDaysTextStyle,
    this.selectedDateTextStyle,
    this.selectedWeekDaysTextStyle,
    this.endDate,
    this.initialDate,
    this.autoScroll = true,
    this.controller,
    required this.selectedMonth,
    required this.onUserPicked,
  });

  /// The month displayed in this view.
  final DateTime selectedMonth;

  /// Callback fired with the picked date when tapped.
  final void Function(DateTime) onUserPicked;

  /// Decoration applied to non-selected date cells.
  final BoxDecoration? decoration;

  /// Decoration applied to the currently selected date cell.
  final BoxDecoration? userPickedDecoration;

  /// Optional widget used for unselected date cells.
  final Widget? defaultChild;

  /// Optional widget used for the selected date cell.
  final Widget? userPickedChild;

  /// Whether to show the month/year picker header above the list.
  final bool showMonthYearPicker;

  /// Whether to display the weekday labels under each date.
  final bool showWeekDays;

  /// Style applied to the header text in the month/year picker.
  final TextStyle? headerTextStyle;

  /// Color used for header navigation icons.
  final Color? headerIconColor;

  /// Height used by the month/year picker when displayed.
  final double? headerHeight;

  /// Color used for the selected month item in the month picker.
  final Color? monthYearPickerSelectedMonthColor;

  /// Color used for unselected month items in the month picker.
  final Color? monthYearPickerUnselectedMonthColor;

  /// Number of columns used when showing months in the picker grid.
  final int? monthYearPickerCrossAxisCount;

  /// Child aspect ratio used for month tiles in the picker grid.
  final double? monthYearPickerChildAspectRatio;

  /// Decoration applied to each month item inside the month picker.
  final BoxDecoration? monthYearPickerMonthItemDecoration;

  /// Text style used for the date number in non-selected cells.
  final TextStyle? dateTextStyle;

  /// Text style used for the weekday label in non-selected cells.
  final TextStyle? weekDaysTextStyle;

  /// Text style used for the date number in the selected cell.
  final TextStyle? selectedDateTextStyle;

  /// Text style used for the weekday label in the selected cell.
  final TextStyle? selectedWeekDaysTextStyle;

  /// Optional date to scroll to on first build (if [autoScroll] is true) and earliest selectable date.
  final DateTime? initialDate;

  /// If true the view will automatically scroll to [initialDate] when first built.
  final bool autoScroll;

  /// Optional latest selectable date. Dates after this will be unselectable.
  final DateTime? endDate;

  /// Optional controller to programmatically drive calendar navigation and selections.
  final MCalendarController? controller;

  @override
  State<HorizontalView> createState() => _HorizontalViewState();
}

class _HorizontalViewState extends State<HorizontalView> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolled = false;

  /// Returns a date-only copy of [date] (time components removed).
  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<HorizontalCalendarProvider>(
      context,
      listen: false,
    );
    widget.controller?.attach(provider);
  }

  @override
  void didUpdateWidget(HorizontalView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final provider = Provider.of<HorizontalCalendarProvider>(
      context,
      listen: false,
    );

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      widget.controller?.attach(provider);
    }

    if (oldWidget.selectedMonth.year != widget.selectedMonth.year ||
        oldWidget.selectedMonth.month != widget.selectedMonth.month) {
      provider.setSelectedMonth(widget.selectedMonth);
      _hasScrolled = false;
    }
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _scrollController.dispose();
    super.dispose();
  }

  void _maybeScrollToInitial(HorizontalCalendarProvider provider) {
    if (_hasScrolled || !widget.autoScroll || !_scrollController.hasClients) {
      return;
    }
    final initial = widget.initialDate;
    if (initial == null) return;

    final days = provider.daysInMonth;
    final idx = days.indexWhere(
      (d) =>
          d.year == initial.year &&
          d.month == initial.month &&
          d.day == initial.day,
    );
    if (idx != -1) {
      const itemExtent = 68.0;
      final offset = (idx * itemExtent - 120.0).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    _hasScrolled = true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HorizontalCalendarProvider>(
      builder: (context, provider, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _maybeScrollToInitial(provider);
        });

        return Column(
          children: [
            if (widget.showMonthYearPicker)
              CalendarHeaderView(
                displayedMonth: provider.selectedMonth,
                onMonthChanged: (value) {
                  provider.setSelectedMonth(value);
                },
                textStyle: widget.headerTextStyle,
                iconColor: widget.headerIconColor,
                height: widget.headerHeight ?? 320,
                selectedMonthColor: widget.monthYearPickerSelectedMonthColor,
                unselectedMonthColor:
                    widget.monthYearPickerUnselectedMonthColor,
                crossAxisCount: widget.monthYearPickerCrossAxisCount ?? 3,
                childAspectRatio: widget.monthYearPickerChildAspectRatio ?? 1.5,
                monthItemDecoration: widget.monthYearPickerMonthItemDecoration,
              ),
            Expanded(
              child: ListView(
                key: const Key('horizontal_calendar_list'),
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                children:
                    provider.daysInMonth.map((date) {
                      final isSelected =
                          provider.selectedDay.year == date.year &&
                          provider.selectedDay.month == date.month &&
                          provider.selectedDay.day == date.day;

                      final markedModel = provider.markedModelFor(date);

                      final isAfterStart =
                          widget.initialDate == null ||
                          !_dateOnly(
                            date,
                          ).isBefore(_dateOnly(widget.initialDate!));
                      final isBeforeEnd =
                          widget.endDate == null ||
                          !_dateOnly(date).isAfter(_dateOnly(widget.endDate!));
                      final bool isSelectable = isAfterStart && isBeforeEnd;

                      return Semantics(
                        button: isSelectable,
                        enabled: isSelectable,
                        selected: isSelected,
                        label: date.toString().split(' ').first,
                        child: GestureDetector(
                          onTap:
                              isSelectable
                                  ? () => provider.setSelectedDay(date)
                                  : null,
                          child: Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.all(4),
                            decoration:
                                isSelected
                                    ? widget.userPickedDecoration ??
                                        BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        )
                                    : markedModel != null
                                    ? markedModel.decoration
                                    : widget.decoration ??
                                        BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                            alignment: Alignment.center,
                            child:
                                isSelected
                                    ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        widget.userPickedChild ??
                                            Text(
                                              '${date.day}',
                                              style:
                                                  widget
                                                      .selectedDateTextStyle ??
                                                  const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                            ),
                                        if (widget.showWeekDays)
                                          Text(
                                            DateFormat('E').format(date),
                                            style:
                                                widget
                                                    .selectedWeekDaysTextStyle ??
                                                const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                          ),
                                      ],
                                    )
                                    : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        widget.defaultChild ??
                                            Text(
                                              '${date.day}',
                                              style:
                                                  widget.dateTextStyle ??
                                                  TextStyle(
                                                    color:
                                                        isSelectable
                                                            ? Colors.black
                                                            : Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                            ),
                                        if (widget.showWeekDays)
                                          Text(
                                            DateFormat('E').format(date),
                                            style:
                                                widget.weekDaysTextStyle ??
                                                TextStyle(
                                                  color:
                                                      isSelectable
                                                          ? Colors.grey
                                                          : Colors
                                                              .grey
                                                              .shade400,
                                                  fontSize: 12,
                                                ),
                                          ),
                                      ],
                                    ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

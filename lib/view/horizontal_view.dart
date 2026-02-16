import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m_calendar/view/calendar_header_view.dart';
import 'package:provider/provider.dart';

import '../provider/calendar_header_provider.dart';
import '../provider/horizontal_calendar_provider.dart';

/// A horizontally scrollable calendar widget that shows a month's days in a
/// single row. The widget supports marking days, custom cell widgets/decoration
/// and an optional month/year picker header.
class HorizontalView extends StatefulWidget {
  /// Creates a new instance of the [HorizontalView] widget with default values.
  ///
  /// This constructor initializes `initialDate` and `endDate` to `DateTime.now()`
  /// and enables `autoScroll` by default.
  HorizontalView.defaults({
    Key? key,
    this.decoration,
    this.userPickedDecoration,
    this.defaultChild,
    this.userPickedChild,
    required this.showMonthYearPicker,
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
  }) : initialDate = DateTime.now(),
       endDate = DateTime.now(),
       autoScroll = true;

  /// Creates a new instance of the [HorizontalView] widget.
  ///
  /// [showMonthYearPicker] controls whether the month/year picker header is
  /// shown. [initialDate] (optional) determines where the list will auto-scroll
  /// on first build when [autoScroll] is true.
  const HorizontalView({
    super.key,
    this.decoration,
    this.userPickedDecoration,
    this.defaultChild,
    this.userPickedChild,
    required this.showMonthYearPicker,
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
  });

  /// Decoration applied to non-selected date cells.
  final BoxDecoration? decoration;

  /// Decoration applied to the currently selected date cell.
  final BoxDecoration? userPickedDecoration;

  /// Optional widget used for unselected date cells. If null a default
  /// vertically stacked day + weekday layout is used.
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

  /// Optional date to scroll to on first build (if [autoScroll] is true).
  final DateTime? initialDate;

  /// If true the view will automatically scroll to [initialDate] when
  /// first built. Defaults to `true` but can be set to `false` to let
  /// external layout or controllers manage initial offset.
  final bool autoScroll;

  /// Optional last selectable date. Dates after this will be considered
  /// unselectable.
  final DateTime? endDate;

  @override
  State<HorizontalView> createState() => _HorizontalViewState();
}

class _HorizontalViewState extends State<HorizontalView> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolled = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _maybeScrollToInitial(HorizontalCalendarProvider provider) {
    if (_hasScrolled || !widget.autoScroll) return;
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
      // each item is 60 wide plus 8 margin (4 each side)
      const itemExtent = 68.0;
      final offset = idx * itemExtent - 120.0;
      // animated scroll for a bit of polish
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
        // attempt scrolling after provider has been built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _maybeScrollToInitial(provider);
        });

        return Column(
          children: [
            if (widget.showMonthYearPicker)
              ChangeNotifierProvider(
                create: (BuildContext context) {
                  return CalendarHeaderProvider(provider.selectedMonth);
                },
                child: CalendarHeaderView(
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
                  childAspectRatio:
                      widget.monthYearPickerChildAspectRatio ?? 1.5,
                  monthItemDecoration:
                      widget.monthYearPickerMonthItemDecoration,
                ),
              ),
            Expanded(
              child: ListView(
                key: const Key('horizontal_calendar_list'),
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                children:
                    provider.daysInMonth.map((date) {
                      final isSelected =
                          provider.selectedDay.day == date.day &&
                          provider.selectedDay.month == date.month;

                      final isMarked = provider.isMarked(date);
                      final start =
                          widget.initialDate?.add(const Duration(days: -1)) ??
                          DateTime.now().add(const Duration(days: -1));
                      final end =
                          widget.endDate ??
                          DateTime.now().add(const Duration(days: 30));
                      bool isSelectable =
                          !date.isBefore(start) && !date.isAfter(end);

                      return GestureDetector(
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
                                        borderRadius: BorderRadius.circular(10),
                                      )
                                  : isMarked
                                  ? provider.markedDaysList!.first.decoration
                                  : widget.decoration ??
                                      BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                          alignment: Alignment.center,
                          child:
                              isSelected
                                  ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      widget.userPickedChild ??
                                          Text(
                                            '${date.day}',
                                            style:
                                                widget.selectedDateTextStyle ??
                                                const TextStyle(
                                                  color: Colors.white,

                                                  fontSize: 16,
                                                ),
                                          ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('EEE').format(date),
                                        style:
                                            widget.selectedWeekDaysTextStyle ??
                                            const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  )
                                  : widget.defaultChild ??
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${date.day}',
                                            style:
                                                widget.dateTextStyle ??
                                                TextStyle(
                                                  color: Colors.black
                                                      .withValues(
                                                        alpha:
                                                            isSelectable
                                                                ? 1
                                                                : 0.5,
                                                      ),
                                                  fontSize: 16,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat('EEE').format(date),
                                            style:
                                                widget.weekDaysTextStyle ??
                                                TextStyle(
                                                  color: Colors.black
                                                      .withValues(
                                                        alpha:
                                                            isSelectable
                                                                ? 1
                                                                : 0.5,
                                                      ),
                                                  fontSize: 12,
                                                ),
                                          ),
                                        ],
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

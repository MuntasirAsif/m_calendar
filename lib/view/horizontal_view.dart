import 'package:flutter/material.dart';
import 'package:m_calendar/view/calendar_header_view.dart';
import 'package:provider/provider.dart';

import '../provider/calendar_header_provider.dart';
import '../provider/horizontal_calendar_provider.dart';

/// A widget that displays a horizontal calendar view, allowing users to select
class HorizontalView extends StatelessWidget {
  /// Creates a new instance of the [HorizontalView] widget.
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
  });

  /// Creates a new instance of the [HorizontalView] widget.
  final BoxDecoration? decoration;

  /// Creates a new instance of the [HorizontalView] widget.
  final BoxDecoration? userPickedDecoration;

  /// Creates a new instance of the [HorizontalView] widget.
  final Widget? defaultChild;

  /// Creates a new instance of the [HorizontalView] widget.
  final Widget? userPickedChild;

  /// Creates a new instance of the [HorizontalView] widget.
  final bool showMonthYearPicker;

  /// Creates a new instance of the [HorizontalView] widget.
  /// [decoration] The decoration to apply to the selected day.

  /// Creates a new instance of the [HorizontalView] widget.
  final TextStyle? headerTextStyle;

  /// Creates a new instance of the [HorizontalView] widget.
  /// [Color] headerIconColor
  final Color? headerIconColor;

  /// headerHeight
  final double? headerHeight;
  final Color? monthYearPickerSelectedMonthColor;
  final Color? monthYearPickerUnselectedMonthColor;
  final int? monthYearPickerCrossAxisCount;
  final double? monthYearPickerChildAspectRatio;
  final BoxDecoration? monthYearPickerMonthItemDecoration;

  @override
  Widget build(BuildContext context) {
    return Consumer<HorizontalCalendarProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            if (showMonthYearPicker)
              ChangeNotifierProvider(
                create: (BuildContext context) {
                  return CalendarHeaderProvider(provider.selectedMonth);
                },
                child: CalendarHeaderView(
                  onMonthChanged: (value) {
                    provider.setSelectedMonth(value);
                  },
                  textStyle: headerTextStyle,
                  iconColor: headerIconColor,
                  height: headerHeight ?? 320,
                  selectedMonthColor: monthYearPickerSelectedMonthColor,
                  unselectedMonthColor: monthYearPickerUnselectedMonthColor,
                  crossAxisCount: monthYearPickerCrossAxisCount ?? 3,
                  childAspectRatio: monthYearPickerChildAspectRatio ?? 1.5,
                  monthItemDecoration: monthYearPickerMonthItemDecoration,
                ),
              ),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    provider.daysInMonth.map((date) {
                      final isSelected =
                          provider.selectedDay.day == date.day &&
                          provider.selectedDay.month == date.month;

                      final isMarked = provider.isMarked(date);

                      return GestureDetector(
                        onTap: () => provider.setSelectedDay(date),
                        child: Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.all(4),
                          decoration:
                              isSelected
                                  ? userPickedDecoration ??
                                      BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(10),
                                      )
                                  : isMarked
                                  ? provider.markedDaysList!.first.decoration
                                  : decoration ??
                                      BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                          alignment: Alignment.center,
                          child:
                              isSelected
                                  ? userPickedChild ??
                                      Text(
                                        '${date.day}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      )
                                  : defaultChild ?? Text('${date.day}'),
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

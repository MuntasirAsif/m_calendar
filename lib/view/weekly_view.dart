import 'package:flutter/material.dart';
import 'package:m_calendar/provider/weekly_calendar_table_provider.dart';
import 'package:m_calendar/widgets/calendar_week_cell.dart';
import 'package:provider/provider.dart';
import '../model/marked_date_model.dart';

/// A widget that displays the weekly calendar view, showing weeks of a month
/// with the ability to select individual dates.
///
/// This widget allows users to interact with the calendar to select a specific date
/// or range of dates (if enabled). The selected dates are passed back via the `onUserPicked` callback.
class WeeklyView extends StatelessWidget {
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
  });

  /// The currently selected month for the calendar.
  ///
  /// This DateTime object represents the month currently being displayed in the calendar.
  final DateTime selectedMonth;

  /// The decoration applied to the calendar container.
  ///
  /// This is an optional `BoxDecoration` used to style the overall appearance of the calendar.
  final BoxDecoration? decoration;

  /// A list of custom marked days to highlight in the calendar.
  ///
  /// This list contains days that should be visually marked in the calendar, for example, to indicate special events.
  final List<MarkedDaysModel>? markedDaysList;

  /// The style applied to the week name header (e.g., "Week 1", "Week 2").
  ///
  /// This is an optional `TextStyle` used to customize the appearance of the week headers in the table.
  final TextStyle? weekNameHeaderStyle;

  /// The default widget to display inside each week cell.
  ///
  /// This widget is displayed in the calendar cells by default if no other content is provided.
  final Widget? defaultChild;

  /// The decoration applied to user-selected dates.
  ///
  /// This decoration is applied to the calendar cells that represent dates selected by the user.
  final BoxDecoration? userPickedDecoration;

  /// The widget displayed on the user-selected date cells.
  ///
  /// This widget is displayed inside the cells of the selected dates.
  final Widget? userPickedChild;

  /// The padding around each cell in the calendar.
  ///
  /// This `EdgeInsets` defines the padding applied to each calendar cell.
  final EdgeInsets? cellPadding;

  /// A callback triggered when the user selects a date or a range of dates.
  ///
  /// The callback provides a list of `DateTime` objects representing the selected dates.
  final void Function(List<DateTime>) onUserPicked;

  /// A flag indicating if range selection is enabled (default is `false`).
  ///
  /// If this flag is set to `true`, the calendar will allow the user to select a range of dates,
  /// not just individual dates.
  final bool isRangeSelection;

  /// The starting day of the week (default is `Day.saturday`).
  ///
  /// This specifies which day will be considered as the start of the week. The default is Saturday,
  /// but it can be changed to any day by passing a different value from the `Day` enum.
  final Day startDay;

  @override
  Widget build(BuildContext context) {
    return Consumer<WeeklyCalenderTableProvider>(
      builder: (_, provider, __) {
        final monthWeekMap = provider.monthWeekMap;
        final months = monthWeekMap.keys.toList();

        return Table(
          columnWidths: const {
            0: FixedColumnWidth(60), // Fixed width for month labels
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // WEEK HEADER ROW
            TableRow(
              children: [
                const SizedBox(), // Empty top-left cell
                ...List.generate(5, (i) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Week ${i + 1}',
                        style:
                            weekNameHeaderStyle ??
                            const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                      ),
                    ),
                  );
                }),
              ],
            ),

            // MONTH ROWS
            ...months.map((monthLabel) {
              final weeks = monthWeekMap[monthLabel]!;

              return TableRow(
                children: [
                  // Month label
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      monthLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // Week cells (up to 5 weeks per month)
                  ...List.generate(5, (i) {
                    final week = i < weeks.length ? weeks[i] : [];
                    final firstDate =
                        week.isNotEmpty ? week.first : DateTime(0);
                    final lastDate = week.isNotEmpty ? week.last : DateTime(0);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: WeeklyCalendarDateCell(
                        firstDate: firstDate,
                        lastDate: lastDate,
                        isSelected: isSameDay(provider.userPicked, firstDate),
                        onTap: () => provider.toggleUserPicked(firstDate),
                        defaultDecoration: decoration,
                        defaultChild: defaultChild,
                        userPickedDecoration: userPickedDecoration,
                        userPickedChild: userPickedChild,
                        cellPadding: cellPadding,
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        );
      },
    );
  }
}

/// Helper function to compare two DateTime objects to check if they represent the same day.
///
/// This function compares only the year, month, and day parts of two `DateTime` objects.
///
/// Returns `true` if both `DateTime` objects are on the same day, otherwise returns `false`.
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

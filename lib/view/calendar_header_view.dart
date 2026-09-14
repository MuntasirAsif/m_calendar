import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../provider/calendar_header_provider.dart';

/// Widget that displays the calendar header, allowing users to navigate between months.
/// Customizable for colors, text style, icons, and decorations.
class CalendarHeaderView extends StatelessWidget {
  /// Constructor for CalendarHeaderView
  ///
  ///   * [onMonthChanged] - Callback when month changes
  ///   * [displayedMonth] - Optional direct month to display (avoids provider requirement)
  ///   * [textStyle] - Text style for the month/year label
  ///   * [iconColor] - Color for the previous/next arrow icons
  ///   * [selectedMonthColor] - Color of selected month in the picker grid
  ///   * [unselectedMonthColor] - Color of unselected months in the picker grid
  ///   * [monthItemDecoration] - Decoration for each month cell
  ///   * [height] - Height of the bottom sheet
  ///   * [crossAxisCount] - Number of columns in month grid
  ///   * [childAspectRatio] - Aspect ratio for month grid items
  ///
  const CalendarHeaderView({
    super.key,
    required this.onMonthChanged,
    this.displayedMonth,
    this.textStyle,
    this.iconColor,
    this.selectedMonthColor,
    this.unselectedMonthColor,
    this.monthItemDecoration,
    this.height = 320,
    this.crossAxisCount = 3,
    this.childAspectRatio = 2.5,
  });

  /// Callback when month changes
  final ValueChanged<DateTime> onMonthChanged;

  /// The currently displayed month. If provided, overrides [CalendarHeaderProvider].
  final DateTime? displayedMonth;

  /// Text style for the month/year label
  final TextStyle? textStyle;

  /// Color for the previous/next arrow icons
  final Color? iconColor;

  /// Color of selected month in the picker grid
  final Color? selectedMonthColor;

  /// Color of unselected months in the picker grid
  final Color? unselectedMonthColor;

  /// Decoration for each month cell
  final BoxDecoration? monthItemDecoration;

  /// Height of the bottom sheet
  final double height;

  /// Number of columns in month grid
  final int crossAxisCount;

  /// Aspect ratio for month grid items
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final headerProvider = Provider.of<CalendarHeaderProvider?>(context);
    final selectedMonth =
        displayedMonth ?? headerProvider?.selectedMonth ?? DateTime.now();
    final formattedMonth = DateFormat('MMMM yyyy').format(selectedMonth);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: MaterialLocalizations.of(context).previousMonthTooltip,
          icon: Icon(Icons.chevron_left, color: iconColor),
          onPressed: () {
            final prev = DateTime(selectedMonth.year, selectedMonth.month - 1);
            headerProvider?.previousMonth();
            onMonthChanged(prev);
          },
        ),
        Semantics(
          button: true,
          label: 'Change month',
          child: GestureDetector(
            onTap:
                () => _showMonthYearPicker(
                  context,
                  selectedMonth,
                  headerProvider,
                ),
            child: Text(
              formattedMonth,
              style: textStyle ?? Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
          icon: Icon(Icons.chevron_right, color: iconColor),
          onPressed: () {
            final next = DateTime(selectedMonth.year, selectedMonth.month + 1);
            headerProvider?.nextMonth();
            onMonthChanged(next);
          },
        ),
      ],
    );
  }

  void _showMonthYearPicker(
    BuildContext context,
    DateTime currentMonth,
    CalendarHeaderProvider? provider,
  ) {
    int tempYear = currentMonth.year;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: height,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Previous year',
                        onPressed: () => setState(() => tempYear--),
                        icon: Icon(Icons.chevron_left, color: iconColor),
                      ),
                      Text(
                        '$tempYear',
                        style:
                            textStyle ??
                            const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        tooltip: 'Next year',
                        onPressed: () => setState(() => tempYear++),
                        icon: Icon(Icons.chevron_right, color: iconColor),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: 12,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (_, index) {
                        final month = index + 1;
                        final monthName = DateFormat(
                          'MMM',
                        ).format(DateTime(tempYear, month));

                        final isSelected =
                            currentMonth.year == tempYear &&
                            currentMonth.month == month;

                        return GestureDetector(
                          onTap: () {
                            final picked = DateTime(tempYear, month);
                            provider?.setMonth(picked);
                            onMonthChanged(picked);
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            alignment: Alignment.center,
                            decoration:
                                monthItemDecoration ??
                                BoxDecoration(
                                  color:
                                      isSelected
                                          ? selectedMonthColor ??
                                              Theme.of(context).primaryColor
                                          : unselectedMonthColor ??
                                              Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                            child: Text(
                              monthName,
                              style:
                                  textStyle?.copyWith(
                                    color:
                                        isSelected
                                            ? selectedMonthColor ?? Colors.white
                                            : unselectedMonthColor ??
                                                Colors.black,
                                  ) ??
                                  TextStyle(
                                    color:
                                        isSelected
                                            ? selectedMonthColor ?? Colors.white
                                            : unselectedMonthColor ??
                                                Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  });

  /// Creates a new instance of the [HorizontalView] widget.
  final BoxDecoration? decoration;

  /// Creates a new instance of the [HorizontalView] widget.
  final BoxDecoration? userPickedDecoration;

  /// Creates a new instance of the [HorizontalView] widget.
  final Widget? defaultChild;

  /// Creates a new instance of the [HorizontalView] widget.
  final Widget? userPickedChild;

  @override
  Widget build(BuildContext context) {
    return Consumer<HorizontalCalendarProvider>(
      builder: (context, provider, _) {
        return ListView(
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
                                  style: const TextStyle(color: Colors.white),
                                )
                            : defaultChild ?? Text('${date.day}'),
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}

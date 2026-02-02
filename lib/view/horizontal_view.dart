import 'package:flutter/material.dart';
import 'package:m_calendar/provider/horizontal_calendar_provider.dart';
import 'package:provider/provider.dart';

/// A placeholder widget for the horizontal calendar view.
class HorizontalView extends StatelessWidget {
  /// Constructs a `HorizontalView` widget.
  const HorizontalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HorizontalCalendarProvider>(
      builder: (
        BuildContext context,
        HorizontalCalendarProvider provider,
        Widget? child,
      ) {
        return ListView(
          scrollDirection: Axis.horizontal,
          children:
              provider.daysInMonth
                  .map(
                    (day) => Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8.0),
                        color:
                            provider.selectedDay.day == day
                                ? Colors.blueAccent
                                : Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          provider.setSelectedDay(
                            DateTime(
                              provider.selectedMonth.year,
                              provider.selectedMonth.month,
                              day,
                            ),
                          );
                        },
                        child: Text(
                          '$day',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}

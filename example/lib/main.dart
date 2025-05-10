import 'package:flutter/material.dart';
import 'package:m_calendar/m_calendar.dart';
import 'package:m_calendar/model/selectedDateModel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Center(
          child: MCalendar(
            selectedMonth: DateTime(2025, 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            selectedDaysList: [
              SelectedDaysModel(
                selectedDateList: [7,12, 14, 16],
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade300, Colors.deepOrange.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade100,
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    )
                  ],
                ),
              ),
              SelectedDaysModel(
                selectedDateList: [5],
                decoration: BoxDecoration(
                  color: Colors.purple.shade600,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.shade100,
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    )
                  ],
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

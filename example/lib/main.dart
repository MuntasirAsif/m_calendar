import 'package:flutter/material.dart';
import 'package:m_calendar/m_calendar.dart';
import 'package:m_calendar/model/marked_date_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      home: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text("Custom MCalendar"),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: Center(
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: MCalendar(
                isRangeSelection: true,
                selectedMonth: DateTime(2025, 5),
                decoration: BoxDecoration(
                  color: const Color(0xffEDEFF1),
                  borderRadius: BorderRadius.circular(32),
                ),
                userPickedDecoration: BoxDecoration(
                  color: const Color(0xffFFCE51),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.deepOrange, width: 2),
                ),
                weekNameHeaderStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                userPickedChild: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                ),
                markedDaysList: [
                  MarkedDaysModel(
                    selectedDateList: [
                      DateTime(2025, 5, 17),
                      DateTime(2025, 5, 20),
                    ],
                    child: const Center(
                      child: Icon(Icons.star, size: 16, color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withAlpha(150),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
                onUserPicked: (value) {
                  debugPrint(value.toString());
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

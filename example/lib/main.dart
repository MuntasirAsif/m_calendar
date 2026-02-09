import 'package:flutter/material.dart';
import 'package:m_calendar/m_calendar.dart';
import 'package:m_calendar/model/marked_date_model.dart';
import 'package:m_calendar/provider/weekly_calendar_table_provider.dart';

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
          title: const Text("MCalendar"),
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  MCalendar(
                    selectedMonth: DateTime.now(),
                    isRangeSelection: true,
                    markedDaysList: [
                      MarkedDaysModel(
                        selectedDateList: [
                          DateTime.now().add(const Duration(days: 4)),
                          DateTime.now().add(const Duration(days: 5)),
                        ],
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: .3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    onUserPicked: (value) {
                      debugPrint('User Get: $value');
                    },
                  ),
                  MCalendar.weekly(
                    startDay: Day.sunday,
                    isRangeSelection: false,
                    selectedMonth: DateTime.now(),
                    onUserPicked: (value) {
                      debugPrint('User Get: $value');
                    },
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    height: 300,
                    child: MCalendar.horizontal(
                      selectedMonth: DateTime.now(),
                      onUserPicked: (value) {
                        debugPrint('User Get: $value');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

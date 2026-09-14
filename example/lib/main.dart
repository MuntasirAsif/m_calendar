import 'package:flutter/material.dart';
import 'package:m_calendar/m_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCalendar Demo',
      theme: ThemeData.light(useMaterial3: true),
      home: const CalendarDemoPage(),
    );
  }
}

class CalendarDemoPage extends StatefulWidget {
  const CalendarDemoPage({super.key});

  @override
  State<CalendarDemoPage> createState() => _CalendarDemoPageState();
}

class _CalendarDemoPageState extends State<CalendarDemoPage> {
  String _lastPicked = 'Nothing picked yet';

  static final _markedDates = [
    MarkedDaysModel(
      selectedDateList: [
        DateTime.now().add(const Duration(days: 4)),
        DateTime.now().add(const Duration(days: 5)),
      ],
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    ),
    MarkedDaysModel(
      selectedDateList: [DateTime.now().add(const Duration(days: 10))],
      decoration: const BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('MCalendar Demo'),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ────────────────────────────────────────────────────────────
            // Section: Monthly – single selection + marked dates
            // ────────────────────────────────────────────────────────────
            _sectionLabel('Monthly — single selection + marked dates'),
            MCalendar(
              selectedMonth: DateTime.now(),
              markedDaysList: _markedDates,
              showMonthYearPicker: true,
              onUserPicked: (dates) => _show('Monthly single: $dates'),
            ),
            const SizedBox(height: 24),

            // ────────────────────────────────────────────────────────────
            // Section: Monthly – range selection
            // ────────────────────────────────────────────────────────────
            _sectionLabel('Monthly — range selection'),
            MCalendar(
              selectedMonth: DateTime.now(),
              isRangeSelection: true,
              userPickedDecoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(8),
              ),
              showMonthYearPicker: true,
              onUserPicked:
                  (dates) => _show('Range: ${dates.first} → ${dates.last}'),
            ),
            const SizedBox(height: 24),

            // ────────────────────────────────────────────────────────────
            // Section: Weekly
            // ────────────────────────────────────────────────────────────
            _sectionLabel('Weekly — start day: Sunday, animated'),
            MCalendar.weekly(
              startDay: Day.sunday,
              selectedMonth: DateTime.now(),
              animations: const CalendarAnimations(),
              onUserPicked: (dates) => _show('Weekly: $dates'),
            ),
            const SizedBox(height: 24),

            // ────────────────────────────────────────────────────────────
            // Section: Horizontal
            // ────────────────────────────────────────────────────────────
            _sectionLabel('Horizontal — animated, auto-scroll to today'),
            SizedBox(
              width: double.maxFinite,
              height: 120,
              child: MCalendar.horizontal(
                selectedMonth: DateTime.now(),
                initialDate: DateTime.now(),
                endDate: DateTime.now().add(const Duration(days: 30)),
                markedDaysList: _markedDates,
                animations: const CalendarAnimations(),
                showMonthYearPicker: true,
                onUserPicked: (date) => _show('Horizontal: $date'),
              ),
            ),
            const SizedBox(height: 24),

            // ────────────────────────────────────────────────────────────
            // Section: Monthly – opt-in animations
            //
            // Exercises circle-shaped marked dates animating into a rounded
            // selection, which is the combination that must not throw
            // "A circle cannot have a border radius".
            // ────────────────────────────────────────────────────────────
            _sectionLabel('Monthly — opt-in animations + marked dates'),
            MCalendar(
              selectedMonth: DateTime.now(),
              animations: const CalendarAnimations(),
              markedDaysList: _markedDates,
              userPickedDecoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(10),
              ),
              showMonthYearPicker: true,
              onUserPicked: (dates) => _show('Monthly animated: $dates'),
            ),
            const SizedBox(height: 24),

            // ────────────────────────────────────────────────────────────
            // Last-picked display
            // ────────────────────────────────────────────────────────────
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _lastPicked,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    ),
  );

  void _show(String msg) => setState(() => _lastPicked = msg);
}

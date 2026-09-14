## [1.4.0]

### Added
- **`MCalendarController`** — imperative controller enabling external navigation
  (`nextMonth()`, `previousMonth()`, `setMonth()`), programmatic selection
  (`selectDate()`, `selectRange()`, `clearSelection()`), and selection queries.
- **`dayBuilder` & `DayState`** — allows developers to supply a `CalendarDayBuilder`
  to render completely custom widgets for calendar day cells with state access
  (selected, today, disabled, in-range, marked).
- **Disabled dates** — added `minDate`, `maxDate`, `isDateDisabled`, `disabledDecoration`,
  and `disabledTextStyle` to restrict selectable ranges and style disabled cells.
- **Barrel exports** — `MCalendarController`, `DayState`, `CalendarDayBuilder`,
  `MarkedDaysModel`, and `Day` are now re-exported from
  `package:m_calendar/m_calendar.dart`. Separate sub-package imports are no
  longer needed.
- **`markedModelFor` on `HorizontalCalendarProvider`** — returns the first
  matching `MarkedDaysModel` for a given date, enabling per-model decoration
  in the horizontal view.
- **`maxWeekCount` on `WeeklyCalendarTableProvider`** — exposes the number of
  week columns required (5 or 6) so the view can render all rows without
  truncating months that span 6 weeks.
- **`assert` for invalid horizontal date range** — passing `initialDate` after
  `endDate` now throws a clear debug assertion instead of silently misbehaving.
- **Accessibility** — added `Semantics(button, enabled, selected, label)` wrappers on
  monthly date cells; added `tooltip` to all header `IconButton`s using
  `MaterialLocalizations` where available.
- **Tests** — expanded test suite with 33 automated tests covering monthly
  normalization, leap years, range selection (sorted/same-day/reset), weekly
  6-week months, year-wrap, marked-date lookup, controller navigation, custom day
  builders, disabled dates, and deprecated aliases.

### Fixed
- **6-week month data loss** — `WeeklyCalendarTableProvider` previously dropped
  the 6th week of months that span 6 calendar rows. All days are now preserved
  and the table header adapts automatically.
- **Horizontal marked-date decoration** — the horizontal view previously always
  used `markedDaysList.first.decoration` for every marked date, regardless of
  which model actually matched. It now uses the correct model's decoration.
- **Horizontal `isSelected` year check** — date equality now compares year,
  month, and day; previously only month and day were compared, causing false
  matches across different years.
- **Date normalization** — `initializeMonth` on both monthly and weekly
  providers now strips the day/time components from `selectedMonth`, so
  `DateTime(2024, 3, 15, 10, 30)` and `DateTime(2024, 3)` produce identical
  state.
- **`setSelectedMonth` normalization** — `HorizontalCalendarProvider` now
  normalizes the incoming month to year/month only.

### Changed
- **`MonthlyCalenderTableProvider` → `MonthlyCalendarTableProvider`** —
  corrected the "calender" typo. The old name is kept as a `@Deprecated`
  typedef alias for backward compatibility.
- **`WeeklyCalenderTableProvider` → `WeeklyCalendarTableProvider`** — same
  typo fix with a `@Deprecated` alias.
- **Weekly week map is now cached** — `_generateWeeksByMonth()` runs once in
  `initializeMonth` instead of being re-evaluated on every getter access.
- **Header `IconButton` tooltips** — previous/next month buttons now carry
  tooltips from `MaterialLocalizations` (screen-reader friendly).
- **`Semantics` on date cells** — monthly date cells now expose
  `button: true`, `selected`, and a `label` with the ISO date string to
  assistive technologies.

### Deprecated
- `MonthlyCalenderTableProvider` — use `MonthlyCalendarTableProvider`.
- `WeeklyCalenderTableProvider` — use `WeeklyCalendarTableProvider`.

---

## [1.3.5]
- Add horizontal view calendar with custom decoration
- Update Redme.md

## [1.3.4]
- Add horizontal view calendar with custom decoration
- Add horizontal view calendar with custom decoration and custom child widget
- Add horizontal auto scrollable calendar 
- Update Redme.md

## [1.3.2]
- Add horizontal view calendar
- Add horizontal scrollable calendar
- Add horizontal scrollable calendar with custom decoration
- Add horizontal scrollable calendar with custom decoration and custom child widget
- Update Redme.md

## [1.2.1]
- Update preview gif

## [1.2.0]

### Added
- Introduced `MCalendar.weekly` for weekly calendar view with full week display.
- Users can now select a range of dates on a weekly calendar, improving flexibility.

### Fixed
- Fixed UI alignment issues for weekly view cells.
- Improved logic for handling date ranges in `MCalendar.weekly`.
- Corrected month-week mapping for consistent weekly view rendering.

### Changed
- Modularized week layout and date selection logic for better maintainability.
- Updated `MCalendar` constructor to support both monthly and weekly views seamlessly.

### Improved
- Enhanced styling and theming options for `MCalendar.weekly`.
- Simplified the weekly calendar's cell padding and decoration logic.


## [1.1.2]

### Fixed
- Test folder added for CI support.
- Updated **CI/CD** GitHub workflow.
- Internal _refactoring_ and _cleanup_.

## [1.1.1]

- Fix Example & example in `README.md`

## [1.1.0]

- User can get the pick date data as a list of DateTime, not just a single DateTime.
- Modularized `CalendarDateCell` and `getRangeDecoration` logic
- Fixed logical prioritization in decoration application for user-picked and range cells
- Improved `MCalendar` UI with card layout, theme consistency, and styling polish
- Added full Dart documentation for all public classes and functions

## [1.0.2]

- Beautified calendar example in `README.md`
- Added full Dart documentation for all public classes and functions
- Modularized `CalendarDateCell` and `getRangeDecoration` logic
- Improved `MCalendar` UI with card layout, theme consistency, and styling polish
- Fixed logical prioritization in decoration application for user-picked and range cells

## [1.0.1]

- Optimized `CalendarDateCell` behavior
- Added support for custom child widgets for user-picked cells
- Enhanced default decoration fallback handling

## [1.0.0]

- First stable release.
- Added user-picked date customizable decoration.
- Improved documentation and structure.

## [0.0.4]

- Update public documentation

## [0.0.3]

- Add user selection option (both single date & range date selection)
- Improved documentation coverage to meet pub.dev analysis requirements.
- Renamed `selectedDateModel.dart` to `selected_date_model.dart` for Dart style compliance.
- Cleaned up formatting and resolved all lint issues.

## [0.0.2]

- Customizable calendar widget with customizable header styling.

## [0.0.1]

- Initial release of the `m_calendar` package.
- Provides a customizable calendar widget with date selection and styling options.

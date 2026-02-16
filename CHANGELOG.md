## [1.3.3]
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

import 'package:flutter/widgets.dart';

/// Opt-in animation configuration for [MCalendar] views.
///
/// Animations are disabled by default: pass a [CalendarAnimations] instance to
/// `MCalendar`, `MCalendar.monthly`, `MCalendar.weekly`, or
/// `MCalendar.horizontal` to enable them. Use [CalendarAnimations.none] to
/// explicitly disable animation when a value is required.
///
/// All durations are automatically forced to [Duration.zero] when the platform
/// requests reduced motion (`MediaQueryData.disableAnimations`), so the calendar
/// remains accessible without extra work from the caller.
///
/// ```dart
/// MCalendar(
///   selectedMonth: DateTime.now(),
///   animations: const CalendarAnimations(),
///   onUserPicked: (dates) => print(dates),
/// )
/// ```
class CalendarAnimations {
  /// Creates an animation configuration.
  ///
  /// Defaults are intentionally short (150-250ms) so interactions feel
  /// responsive rather than sluggish.
  const CalendarAnimations({
    this.selectionDuration = const Duration(milliseconds: 180),
    this.selectionCurve = Curves.easeOut,
    this.monthTransitionDuration = const Duration(milliseconds: 250),
    this.monthTransitionCurve = Curves.easeOutCubic,
    this.sizeDuration = const Duration(milliseconds: 200),
  });

  /// Duration of cell/selection decoration transitions (monthly, weekly,
  /// horizontal, and month-picker tiles).
  final Duration selectionDuration;

  /// Curve applied to selection decoration transitions.
  final Curve selectionCurve;

  /// Duration of the fade + slide transition played when the displayed month
  /// changes in the monthly and weekly grids.
  final Duration monthTransitionDuration;

  /// Curve applied to the month-change transition.
  final Curve monthTransitionCurve;

  /// Duration used when the grid animates between different row counts (for
  /// example a 5-row month followed by a 6-row month).
  final Duration sizeDuration;

  /// A configuration that disables every animation (instant updates).
  static const CalendarAnimations none = CalendarAnimations(
    selectionDuration: Duration.zero,
    monthTransitionDuration: Duration.zero,
    sizeDuration: Duration.zero,
  );

  /// Resolves [duration] to [Duration.zero] when it is `null` (animations are
  /// opted out) or when the platform requests reduced motion.
  static Duration resolve(BuildContext context, Duration? duration) {
    if (duration == null) return Duration.zero;
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return Duration.zero;
    }
    return duration;
  }

  /// Convenience accessor for the resolved selection duration of [animations].
  static Duration selectionOf(
    BuildContext context,
    CalendarAnimations? animations,
  ) => resolve(context, animations?.selectionDuration);

  /// Convenience accessor for the resolved month-transition duration.
  static Duration monthTransitionOf(
    BuildContext context,
    CalendarAnimations? animations,
  ) => resolve(context, animations?.monthTransitionDuration);

  /// Convenience accessor for the resolved grid resize duration.
  static Duration sizeOf(
    BuildContext context,
    CalendarAnimations? animations,
  ) => resolve(context, animations?.sizeDuration);
}

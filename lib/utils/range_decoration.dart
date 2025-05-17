import 'package:flutter/material.dart';

/// Returns a [BoxDecoration] for a date cell based on its position in a selected date range.
///
/// This function applies custom styling depending on whether the date `i` is:
/// - The start of the selected range
/// - The end of the selected range
/// - Within the selected range (but not start or end)
///
/// If the date is not within the range, it returns a default fallback decoration.
///
/// ### Parameters:
/// - [context]: The build context (can be used for theme access if needed).
/// - [i]: The day of the month (1-based).
/// - [rangeStart]: The starting day of the selected range.
/// - [rangeEnd]: The ending day of the selected range.
/// - [defaultDecoration]: The fallback decoration to use when not in range.
/// - [baseColor]: The color used for range highlight decorations.
///
/// ### Returns:
/// A [BoxDecoration] customized based on the range position.
BoxDecoration getRangeDecoration({
  required BuildContext context,
  required int i,
  required int? rangeStart,
  required int? rangeEnd,
  BoxDecoration? defaultDecoration,
  required Color baseColor,
}) {
  if (rangeStart == rangeEnd) {
    return BoxDecoration(
      color: baseColor.withAlpha(100),
      borderRadius: BorderRadius.circular(32),
    );
  }
  if (i == rangeStart) {
    return BoxDecoration(
      color: baseColor.withAlpha(100),
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(32)),
    );
  }

  if (i == rangeEnd) {
    return BoxDecoration(
      color: baseColor.withAlpha(100),
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(32)),
    );
  }

  if (rangeStart != null &&
      rangeEnd != null &&
      i > rangeStart &&
      i < rangeEnd) {
    return BoxDecoration(
      color: baseColor.withAlpha(100),
      borderRadius: BorderRadius.zero,
    );
  }

  return defaultDecoration ??
      BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      );
}

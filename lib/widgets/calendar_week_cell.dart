import 'package:flutter/material.dart';

class WeeklyCalendarDateCell extends StatelessWidget {
  final int i;
  final bool isSelected;
  final VoidCallback? onTap;
  final BoxDecoration? defaultDecoration;
  final Widget? defaultChild;
  final BoxDecoration? userPickedDecoration;
  final Widget? userPickedChild;
  final EdgeInsets? cellPadding;

  const WeeklyCalendarDateCell({
    super.key,
    required this.i,
    required this.isSelected,
    this.onTap,
    this.defaultDecoration,
    this.defaultChild,
    this.userPickedDecoration,
    this.userPickedChild,
    this.cellPadding,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = isSelected
        ? userPickedDecoration ?? BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(6))
        : defaultDecoration ?? BoxDecoration(border: Border.all(color: Colors.grey.shade300));

    final child = isSelected
        ? userPickedChild ?? Text(i.toString(), style: const TextStyle(color: Colors.white))
        : defaultChild ?? Text(i.toString());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: cellPadding ?? const EdgeInsets.all(12),
        decoration: decoration,
        child: Center(child: child),
      ),
    );
  }
}

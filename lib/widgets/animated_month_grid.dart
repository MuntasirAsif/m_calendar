import 'package:flutter/material.dart';

/// Plays a short fade + directional slide whenever [month] changes, and
/// smoothly animates its own height between children with different row counts.
///
/// This intentionally uses a single animated child (via [TweenAnimationBuilder]
/// keyed on [month]) instead of an [AnimatedSwitcher]. With an [AnimatedSwitcher]
/// the outgoing grid keeps listening to the shared provider and would rebuild
/// with the *new* month's data mid-transition, which is visually incorrect.
class AnimatedMonthGrid extends StatefulWidget {
  /// Creates an animated wrapper for a month grid.
  const AnimatedMonthGrid({
    super.key,
    required this.month,
    required this.duration,
    required this.curve,
    this.sizeDuration = Duration.zero,
    required this.child,
  });

  /// The month currently rendered by [child]; a change triggers the transition.
  final DateTime month;

  /// Duration of the fade + slide transition. [Duration.zero] disables it.
  final Duration duration;

  /// Curve applied to the fade + slide transition.
  final Curve curve;

  /// Duration used to animate height changes between different row counts.
  final Duration sizeDuration;

  /// The grid to render.
  final Widget child;

  @override
  State<AnimatedMonthGrid> createState() => _AnimatedMonthGridState();
}

class _AnimatedMonthGridState extends State<AnimatedMonthGrid> {
  bool _forward = true;

  @override
  void didUpdateWidget(AnimatedMonthGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.month.isBefore(oldWidget.month)) {
      _forward = false;
    } else if (widget.month.isAfter(oldWidget.month)) {
      _forward = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final content =
        widget.duration == Duration.zero
            ? widget.child
            : TweenAnimationBuilder<double>(
              key: ValueKey<DateTime>(widget.month),
              tween: Tween<double>(begin: 0, end: 1),
              duration: widget.duration,
              curve: widget.curve,
              builder: (context, t, child) {
                return Opacity(
                  opacity: t.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset((1 - t) * (_forward ? 24 : -24), 0),
                    child: child,
                  ),
                );
              },
              child: widget.child,
            );

    // AnimatedSize must be skipped for a zero duration: its internal
    // controller would complete synchronously inside performLayout and call
    // markNeedsLayout while the render object is still being laid out, which
    // trips a framework assertion.
    if (widget.sizeDuration == Duration.zero) {
      return content;
    }

    return AnimatedSize(
      duration: widget.sizeDuration,
      alignment: Alignment.topCenter,
      curve: Curves.easeOut,
      child: content,
    );
  }
}

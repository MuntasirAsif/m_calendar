import 'package:flutter/material.dart';

/// Returns [target] forced to share [base]'s [BoxShape].
///
/// `AnimatedContainer` interpolates between [BoxDecoration]s with a
/// [DecorationTween]. Lerping between a circle and a rounded rectangle yields an
/// invalid intermediate decoration (a circle carrying a `borderRadius`), which
/// throws "A circle cannot have a border radius" while painting. Keeping the
/// shape stable across the transition avoids the crash.
///
/// When the shapes differ, [target] keeps its colors/gradients/borders but is
/// re-rendered with [base]'s shape. A `borderRadius` cannot be carried onto a
/// circle, so it is dropped (copyWith cannot clear a field, so the decoration
/// is rebuilt).
BoxDecoration? withShapeOf(BoxDecoration? base, BoxDecoration? target) {
  if (base == null || target == null) return target;
  if (base.shape == target.shape) return target;
  if (base.shape == BoxShape.circle) {
    return BoxDecoration(
      color: target.color,
      image: target.image,
      border: target.border,
      boxShadow: target.boxShadow,
      gradient: target.gradient,
      backgroundBlendMode: target.backgroundBlendMode,
      shape: BoxShape.circle,
    );
  }
  return target.copyWith(shape: base.shape);
}

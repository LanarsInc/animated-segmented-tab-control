import 'package:flutter/material.dart';

/// Selection option for [SegmentedTabControl]
@immutable
class SegmentTab {
  const SegmentTab({
    required this.label,
    this.color,
    this.gradient,
    this.selectedTextColor,
    this.backgroundColor,
    this.backgroundGradient,
    this.textColor,
    this.splashColor,
    this.splashHighlightColor,
    this.flex = 1,
  });

  /// This text will be displayed on tab.
  final String label;

  /// Tab flex factor
  final int flex;

  /// Indicator color while this option is selected.
  ///
  /// Overrides the color and the gradient of
  /// [SegmentedTabControl.indicatorDecoration].
  ///
  /// If [gradient] is also specified, [color] has no effect.
  final Color? color;

  /// Indicator gradient while this option is selected.
  ///
  /// Overrides the color and the gradient of
  /// [SegmentedTabControl.indicatorDecoration],
  /// and takes precedence over [color].
  final Gradient? gradient;

  /// Color of the label inside the indicator while this option is selected.
  ///
  /// Overrides [SegmentedTabControl.selectedTabTextColor].
  final Color? selectedTextColor;

  /// Bar color while this option is selected.
  ///
  /// Overrides the color and the gradient of
  /// [SegmentedTabControl.barDecoration].
  final Color? backgroundColor;

  /// Bar gradient while this option is selected.
  ///
  /// Overrides the color and the gradient of
  /// [SegmentedTabControl.barDecoration],
  /// and takes precedence over [backgroundColor].
  final Gradient? backgroundGradient;

  /// Color of the labels outside the indicator while this option is selected.
  ///
  /// Overrides [SegmentedTabControl.tabTextColor].
  final Color? textColor;

  /// Overrides [splashColor] from [SegmentedTabControl].
  final Color? splashColor;

  /// Overrides [splashHighlightColor] from [SegmentedTabControl].
  final Color? splashHighlightColor;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is SegmentTab &&
        other.label == label &&
        other.flex == flex &&
        other.color == color &&
        other.gradient == gradient &&
        other.selectedTextColor == selectedTextColor &&
        other.backgroundColor == backgroundColor &&
        other.backgroundGradient == backgroundGradient &&
        other.textColor == textColor &&
        other.splashColor == splashColor &&
        other.splashHighlightColor == splashHighlightColor;
  }

  @override
  int get hashCode => Object.hash(
        label,
        flex,
        color,
        gradient,
        selectedTextColor,
        backgroundColor,
        backgroundGradient,
        textColor,
        splashColor,
        splashHighlightColor,
      );
}

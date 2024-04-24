import 'package:flutter/material.dart';

import 'utils/icons.dart';

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
    this.iconPosition,
    this.iconBuilder,
  });

  /// This text will be displayed on tab.
  final String label;

  /// Tab flex factor
  final int flex;

  /// Indicator color when this option is selected.
  ///
  /// Overrides [indicatorColor] from [SegmentedTabControl].
  final Color? color;

  /// Indicator gradient when this option is selected.
  ///
  /// Overrides [indicatorGradient] from [SegmentedTabControl].
  /// If this is specified, [color] has no effect.
  final Gradient? gradient;

  /// Text color when this option is selected.
  ///
  /// Overrides [selectedTabTextColor] from [SegmentedTabControl].
  final Color? selectedTextColor;

  /// [SegmentedTabControl] color when this option is selected.
  ///
  /// Overrides [backgroundColor] from [SegmentedTabControl].
  final Color? backgroundColor;

  /// [SegmentedTabControl] background gradient when this option is selected.
  ///
  /// Overrides [backgroundGradient] from [SegmentedTabControl].
  /// If this is specified, [backgroundColor] has no effect.
  final Gradient? backgroundGradient;

  /// Text color when this option is selected.
  ///
  /// Overrides [tabTextColor] from [SegmentedTabControl].
  final Color? textColor;

  /// Overrides [splashColor] from [SegmentedTabControl].
  final Color? splashColor;

  /// Overrides [splashHighlightColor] from [SegmentedTabControl].
  final Color? splashHighlightColor;

  final IconPosition? iconPosition;

  final Widget Function(Color? color)? iconBuilder;

}

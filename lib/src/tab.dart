import 'package:flutter/material.dart';

/// Selection option for [SegmentedTabControl]
@immutable
class SegmentTab {
  const SegmentTab({
    required this.label,
    this.color,
    this.selectedTextColor,
    this.backgroundColor,
    this.textColor,
    this.splashColor,
    this.splashHighlightColor,
  });

  /// This text will be displayed on tab.
  final String label;

  // All provided properties will replace the colors specified in [RoundedTabBar]
  /// Indicator color when this option is selected.
  ///
  /// Overrides [indicatorColor] from [SegmentedTabControl].
  final Color? color;

  /// Text color when this option is selected.
  ///
  /// Overrides [selectedTabTextColor] from [SegmentedTabControl].
  final Color? selectedTextColor;

  /// [SegmentedTabControl] color when this option is selected.
  ///
  /// Overrides [indicatorColor] from [SegmentedTabControl].
  final Color? backgroundColor;

  /// Text color when this option is selected.
  ///
  /// Overrides [tabTextColor] from [SegmentedTabControl].
  final Color? textColor;

  /// Overrides [splashColor] from [SegmentedTabControl].
  final Color? splashColor;

  /// Overrides [splashHighlightColor] from [SegmentedTabControl].
  final Color? splashHighlightColor;
}

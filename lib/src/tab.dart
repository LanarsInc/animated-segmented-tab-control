import 'package:flutter/material.dart';

/// Selection option for [SegmentedTabControl]
@immutable
class SegmentTab {
  const SegmentTab({
    required this.label,
    this.labelBuilder,
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
  ///
  /// Still required when [labelBuilder] is given, where it is used as the tab's
  /// semantics label.
  final String label;

  /// Builds the content of this tab, overriding [label].
  ///
  /// [color] is the resolved content color for the label layer currently being
  /// painted — [SegmentedTabControl.tabTextColor] outside the indicator and
  /// [SegmentedTabControl.selectedTabTextColor] inside it — already tweened for
  /// the current frame. Plain [Icon] and [Text] descendants inherit it
  /// automatically, so they inverse as the indicator passes over them without
  /// any extra work:
  ///
  /// ```dart
  /// SegmentTab(
  ///   label: 'HOME',
  ///   labelBuilder: (_, __) => const Row(
  ///     mainAxisAlignment: MainAxisAlignment.center,
  ///     children: [Icon(Icons.home, size: 18), SizedBox(width: 4), Text('HOME')],
  ///   ),
  /// )
  /// ```
  ///
  /// Use [color] explicitly for anything that does not inherit it, such as a
  /// [Container] border or an SVG.
  ///
  /// The builder must return the same layout for every [color].
  ///
  /// Content inherits `maxLines: 1`, [TextOverflow.clip] and
  /// [TextAlign.center], matching the [label] path. Set [Text.maxLines]
  /// explicitly to opt out. Nothing constrains a non-text child, so an
  /// oversized one is clipped by the bar rather than resized.
  final Widget Function(BuildContext context, Color color)? labelBuilder;

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

import 'package:flutter/material.dart';

@immutable
class CustomizableTab {
  const CustomizableTab({
    required this.label,
    this.color,
    this.selectedTextColor,
    this.backgroundColor,
    this.textColor,
    this.splashColor,
    this.splashHighlightColor,
  });

  final String label;
  // All provided properties will replace the colors specified in [RoundedTabBar]
  final Color? color;
  final Color? selectedTextColor;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? splashColor;
  final Color? splashHighlightColor;
}

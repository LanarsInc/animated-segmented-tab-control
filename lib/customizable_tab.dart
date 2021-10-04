part of customizable_tab_bar;

@immutable
class CustomizableTab {
  const CustomizableTab({
    required this.label,
    this.selectedColor,
    this.selectedTextColor,
    this.selectedBackgroundColor,
    this.unselectedTextColor,
    this.splashColor,
    this.splashHighlightColor,
  });

  final String label;
  // All provided properties will replace the colors specified in [RoundedTabBar]
  final Color? selectedColor;
  final Color? selectedTextColor;
  final Color? selectedBackgroundColor;
  final Color? unselectedTextColor;
  final Color? splashColor;
  final Color? splashHighlightColor;
}

import 'package:animated_segmented_tab_control/src/utils/double_range.dart';
import 'package:animated_segmented_tab_control/src/utils/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'tab.dart';
import 'utils/custom_clippers.dart';

/// Widget based on [TabController]. Can simply replace [TabBar].
///
/// Requires [TabController], witch can be read from [context] with
/// [DefaultTabController] using. Or you can provide controller in the constructor.
class SegmentedTabControl extends StatelessWidget {
  const SegmentedTabControl({
    Key? key,
    this.height = 46,
    required this.tabs,
    this.controller,
    this.backgroundColor,
    this.backgroundGradient,
    this.tabTextColor,
    this.textStyle,
    this.selectedTextStyle,
    this.selectedTabTextColor,
    this.indicatorColor,
    this.indicatorGradient,
    this.squeezeIntensity = 1,
    this.squeezeDuration = const Duration(milliseconds: 500),
    this.indicatorPadding = EdgeInsets.zero,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.radius = const Radius.circular(20),
    this.splashColor,
    this.splashHighlightColor,
    this.indicatorBorder,
  }) : super(key: key);

  /// Height of the widget.
  ///
  /// [preferredSize] returns this value.
  final double height;

  /// Selection options.
  final List<SegmentTab> tabs;

  /// Can be provided by [DefaultTabController].
  final TabController? controller;

  /// The color of the area beyond the indicator.
  final Color? backgroundColor;

  /// A gradient to use when filling the box.
  ///
  /// If this is specified, [backgroundColor] has no effect.
  final Gradient? backgroundGradient;

  /// Style of all labels. Color will not be applied.
  final TextStyle? textStyle;

  /// Style of selected tab label. Color will not be applied.
  final TextStyle? selectedTextStyle;

  /// The color of the text beyond the indicator.
  final Color? tabTextColor;

  /// The color of the text inside the indicator.
  final Color? selectedTabTextColor;

  /// Color of the indicator.
  final Color? indicatorColor;

  /// A gradient to use when filling the box.
  ///
  /// If this is specified, [indicatorColor] has no effect.
  final Gradient? indicatorGradient;

  /// Intensity of squeeze animation.
  ///
  /// This animation starts when you click on the indicator and stops when you
  /// take your finger off the indicator.
  final double squeezeIntensity;

  /// Duration of squeeze animation.
  ///
  /// This animation starts when you click on the indicator and stops when you
  /// take your finger off the indicator.
  final Duration squeezeDuration;

  /// Only vertical padding will be applied.
  final EdgeInsets indicatorPadding;

  /// Padding of labels.
  final EdgeInsets tabPadding;

  /// Radius of widget and indicator.
  final Radius radius;

  /// Splash color of options.
  final Color? splashColor;

  /// Splash highlight color of options.
  final Color? splashHighlightColor;

  // Indicator border
  final BoxBorder? indicatorBorder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _SegmentedTabControl(
          tabs: tabs,
          height: height,
          controller: controller,
          backgroundColor: backgroundColor,
          backgroundGradient: backgroundGradient,
          tabTextColor: tabTextColor,
          textStyle: textStyle,
          selectedTextStyle: selectedTextStyle,
          selectedTabTextColor: selectedTabTextColor,
          indicatorColor: indicatorColor,
          indicatorGradient: indicatorGradient,
          squeezeIntensity: squeezeIntensity,
          squeezeDuration: squeezeDuration,
          indicatorPadding: indicatorPadding,
          tabPadding: tabPadding,
          radius: radius,
          splashColor: splashColor,
          splashHighlightColor: splashHighlightColor,
          maxWidth: constraints.maxWidth,
          indicatorBorder: indicatorBorder,
        );
      },
    );
  }
}

class _SegmentedTabControl extends StatefulWidget implements PreferredSizeWidget {
  const _SegmentedTabControl({
    Key? key,
    this.height = 46,
    required this.tabs,
    this.controller,
    this.backgroundColor,
    this.backgroundGradient,
    this.tabTextColor,
    this.textStyle,
    this.selectedTextStyle,
    this.selectedTabTextColor,
    this.indicatorColor,
    this.indicatorGradient,
    this.squeezeIntensity = 1,
    this.squeezeDuration = const Duration(milliseconds: 500),
    this.indicatorPadding = EdgeInsets.zero,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.radius = const Radius.circular(20),
    this.splashColor,
    this.splashHighlightColor,
    required this.maxWidth,
    this.indicatorBorder,
  }) : super(key: key);

  final double height;
  final List<SegmentTab> tabs;
  final TabController? controller;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final TextStyle? textStyle;
  final TextStyle? selectedTextStyle;
  final Color? tabTextColor;
  final Color? selectedTabTextColor;
  final Color? indicatorColor;
  final Gradient? indicatorGradient;
  final double squeezeIntensity;
  final Duration squeezeDuration;
  final EdgeInsets indicatorPadding;
  final EdgeInsets tabPadding;
  final Radius radius;
  final Color? splashColor;
  final Color? splashHighlightColor;
  final double maxWidth;
  final BoxBorder? indicatorBorder;

  @override
  _SegmentedTabControlState createState() => _SegmentedTabControlState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _SegmentedTabControlState extends State<_SegmentedTabControl>
    with SingleTickerProviderStateMixin {
  EdgeInsets _currentTilePadding = EdgeInsets.zero;
  Alignment _currentIndicatorAlignment = Alignment.centerLeft;
  late AnimationController _internalAnimationController;
  late Animation<Alignment> _internalAnimation;
  TabController? _controller;

  int _totalFlex = 0;

  double _maxWidth = 0;

  List<double> flexFactors = [];

  List<DoubleRange> alignmentXRanges = [];

  bool get _controllerIsValid => _controller?.animation != null;

  int _internalIndex = 0;

  @override
  void initState() {
    super.initState();
    _maxWidth = widget.maxWidth;
    _internalAnimationController = AnimationController(vsync: this);
    _internalAnimationController.addListener(_handleInternalAnimationTick);
    _calculateTotalFlex();
    _calculateFlexFactors();
  }

  void _handleInternalAnimationTick() {
    setState(() {
      _currentIndicatorAlignment = _internalAnimation.value;
    });
  }

  @override
  void dispose() {
    _internalAnimationController.removeListener(_handleInternalAnimationTick);
    _internalAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _updateTabController();
    super.didChangeDependencies();
  }

  void _calculateTotalFlex() {
    _totalFlex = widget.tabs.fold(0, (previousValue, tab) => previousValue + tab.flex);
  }

  void _calculateFlexFactors() {
    int collectedFlex = 0;
    for (int i = 0; i < widget.tabs.length; i++) {
      collectedFlex += widget.tabs[i].flex;
      flexFactors.add(collectedFlex / _totalFlex);
    }
  }

  @override
  void didUpdateWidget(_SegmentedTabControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _calculateTotalFlex();
      _calculateFlexFactors();
      _updateTabController();
    }
  }

  void _updateTabController() {
    final TabController? newController = widget.controller ?? DefaultTabController.of(context);
    assert(() {
      if (newController == null) {
        throw FlutterError(
          'No TabController for ${widget.runtimeType}.\n'
          'When creating a ${widget.runtimeType}, you must either provide an explicit '
          'TabController using the "controller" property, or you must ensure that there '
          'is a DefaultTabController above the ${widget.runtimeType}.\n'
          'In this case, there was neither an explicit controller nor a default controller.',
        );
      }
      return true;
    }());

    if (newController == _controller) {
      return;
    }

    if (_controllerIsValid) {
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    }

    _controller = newController;
    _calculateTabIndicatorAlignmentRanges();

    if (_controller != null) {
      _controller!.animation!.addListener(_handleTabControllerAnimationTick);
      _currentIndicatorAlignment = _animationValueToAlignment(_controller!.index.toDouble());
    }
  }

  void _handleTabControllerAnimationTick() {
    final currentValue = _controller!.animation!.value;
    _animateIndicatorTo(_animationValueToAlignment(currentValue));
  }

  void _calculateTabIndicatorAlignmentRanges() {
    double computedWidth = 0;
    double alignmentStartX = 0;

    for (int index = 0; index < _controller!.length - 1; index++) {
      final tab = widget.tabs[index];
      final nextTab = widget.tabs[index + 1];

      final tabWidth = (tab.flex / _totalFlex) * _maxWidth;
      final nextTabWidth = (nextTab.flex / _totalFlex) * _maxWidth;

      if (nextTabWidth >= tabWidth) {
        final alignmentEndX = computedWidth + (tabWidth / 2);
        alignmentXRanges.add(DoubleRange(alignmentStartX, alignmentEndX));
        alignmentStartX = alignmentEndX;
      } else {
        final controlPoint = computedWidth + (nextTabWidth / 2);
        alignmentXRanges.add(DoubleRange(alignmentStartX, controlPoint));
        alignmentStartX = computedWidth + tabWidth - (nextTabWidth / 2);
      }

      computedWidth += tabWidth;
    }
    alignmentXRanges.add(DoubleRange(alignmentStartX, computedWidth));
  }

  Alignment _animationValueToAlignment(double? value) {
    if (value == null) {
      return const Alignment(-1, 0);
    }

    final index = value.round();
    final reminder = value - index;
    final x = _calculateTarget(reminder, index);

    _internalIndex = index;
    return _calculateAlignmentFromTarget(x, index);
  }

  double _calculateTarget(double reminder, int index) {
    final tabLeftX = index > 0 ? flexFactors[index - 1] * _maxWidth : 0;
    double target;
    if (reminder > 0) {
      target = tabLeftX + ((reminder * 2) * (alignmentXRanges[index].endInclusive - tabLeftX));
    } else {
      target = tabLeftX + ((reminder * 2) * (tabLeftX - alignmentXRanges[index].start));
    }

    return target;
  }

  Alignment _calculateAlignmentFromTarget(double position, int index) {
    final tabWidth = (widget.tabs[index].flex / _totalFlex) * _maxWidth;
    final currentTabHalfWidth = tabWidth / 2;
    final halfMaxWidth = _maxWidth / 2;

    final x =
        (position - halfMaxWidth + currentTabHalfWidth) / (halfMaxWidth - currentTabHalfWidth);

    return Alignment(x, 0);
  }

  TickerFuture _animateIndicatorTo(Alignment target) {
    _internalAnimation = _internalAnimationController.drive(AlignmentTween(
      begin: _currentIndicatorAlignment,
      end: target,
    ));

    return _internalAnimationController.fling();
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = widget.tabs[_internalIndex];

    final textStyle = widget.textStyle ?? Theme.of(context).textTheme.bodyMedium!;

    final selectedTextStyle = widget.selectedTextStyle ?? textStyle;

    final selectedTabTextColor =
        currentTab.selectedTextColor ?? widget.selectedTabTextColor ?? Colors.white;

    final tabTextColor =
        currentTab.textColor ?? widget.tabTextColor ?? Colors.white.withOpacity(0.7);

    final backgroundColor = currentTab.backgroundColor ??
        widget.backgroundColor ??
        Theme.of(context).colorScheme.background;

    final backgroundGradient = currentTab.backgroundGradient ?? widget.backgroundGradient;

    final indicatorColor =
        currentTab.color ?? widget.indicatorColor ?? Theme.of(context).indicatorColor;

    final indicatorGradient = currentTab.gradient ?? widget.indicatorGradient;

    final borderRadius = BorderRadius.all(widget.radius);

    return DefaultTextStyle(
      style: widget.textStyle ?? DefaultTextStyle.of(context).style,
      child: LayoutBuilder(builder: (context, constraints) {
        _maxWidth = constraints.maxWidth;
        final indicatorWidth =
            ((constraints.maxWidth - widget.indicatorPadding.horizontal) / _totalFlex) *
                widget.tabs[_internalIndex].flex;

        return ClipRRect(
          borderRadius: BorderRadius.all(widget.radius),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: kTabScrollDuration,
                  curve: Curves.ease,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    gradient: backgroundGradient,
                    borderRadius: borderRadius,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: _Labels(
                      radius: widget.radius,
                      splashColor: widget.splashColor,
                      splashHighlightColor: widget.splashHighlightColor,
                      callbackBuilder: _onTabTap(),
                      tabs: widget.tabs,
                      currentIndex: _internalIndex,
                      textStyle: textStyle.copyWith(
                        color: tabTextColor,
                      ),
                      selectedTextStyle: selectedTextStyle.copyWith(
                        color: tabTextColor,
                      ),
                      tabPadding: widget.tabPadding,
                    ),
                  ),
                ),
                Align(
                  alignment: _currentIndicatorAlignment,
                  child: GestureDetector(
                    onPanDown: _onPanDown(),
                    onPanUpdate: _onPanUpdate(constraints),
                    onPanEnd: _onPanEnd(constraints),
                    child: Padding(
                      padding: widget.indicatorPadding,
                      child: _SqueezeAnimated(
                        currentTilePadding: _currentTilePadding,
                        squeezeDuration: widget.squeezeDuration,
                        builder: (_) => AnimatedContainer(
                          duration: kTabScrollDuration,
                          curve: Curves.ease,
                          width: indicatorWidth,
                          height: widget.height - widget.indicatorPadding.vertical,
                          decoration: BoxDecoration(
                            color: indicatorColor,
                            gradient: indicatorGradient,
                            borderRadius: BorderRadius.all(widget.radius),
                            border: widget.indicatorBorder,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _SqueezeAnimated(
                  currentTilePadding: _currentTilePadding,
                  squeezeDuration: widget.squeezeDuration,
                  builder: (squeezePadding) => ClipPath(
                    clipper: RRectRevealClipper(
                      radius: widget.radius,
                      size: Size(
                        indicatorWidth,
                        widget.height - widget.indicatorPadding.vertical - squeezePadding.vertical,
                      ),
                      offset: Offset(
                        _xToPercentsCoefficient(_currentIndicatorAlignment) *
                            (constraints.maxWidth - indicatorWidth),
                        0,
                      ),
                    ),
                    child: IgnorePointer(
                      child: _Labels(
                        radius: widget.radius,
                        splashColor: widget.splashColor,
                        splashHighlightColor: widget.splashHighlightColor,
                        tabs: widget.tabs,
                        currentIndex: _internalIndex,
                        textStyle: textStyle.copyWith(
                          color: selectedTabTextColor,
                        ),
                        selectedTextStyle: selectedTextStyle.copyWith(
                          color: selectedTabTextColor,
                        ),
                        tabPadding: widget.tabPadding,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  VoidCallback Function(int)? _onTabTap() {
    if (_controller!.indexIsChanging) {
      return null;
    }
    return (int index) => () {
          _internalAnimationController.stop();
          _controller!.animateTo(index);
        };
  }

  GestureDragDownCallback? _onPanDown() {
    if (_controller!.indexIsChanging) {
      return null;
    }
    return (details) {
      _internalAnimationController.stop();
      setState(() {
        _currentTilePadding = EdgeInsets.symmetric(vertical: widget.squeezeIntensity);
      });
    };
  }

  GestureDragUpdateCallback? _onPanUpdate(BoxConstraints constraints) {
    if (_controller!.indexIsChanging) {
      return null;
    }
    return (details) {
      double x = _currentIndicatorAlignment.x + details.delta.dx / (constraints.maxWidth / 2);
      if (x < -1) {
        x = -1;
      } else if (x > 1) {
        x = 1;
      }
      setState(() {
        _currentIndicatorAlignment = Alignment(x, 0);
        _internalIndex = _alignmentToIndex(_currentIndicatorAlignment);
      });
    };
  }

  int _alignmentToIndex(Alignment alignment) {
    final currentPosition = _xToPercentsCoefficient(alignment);
    final roundedCurrentPosition = num.parse(currentPosition.toStringAsFixed(2));

    final index = flexFactors.indexWhere((flexFactor) => roundedCurrentPosition <= flexFactor);

    return index == -1 ? _controller!.length - 1 : index;
  }

  /// Converts [Alignment.x] value in range -1..1 to 0..1 percents coefficient
  double _xToPercentsCoefficient(Alignment alignment) {
    return (alignment.x + 1) / 2;
  }

  GestureDragEndCallback _onPanEnd(BoxConstraints constraints) {
    return (details) {
      _animateIndicatorToNearest(
        details.velocity.pixelsPerSecond,
        constraints.maxWidth,
      );
      _updateControllerIndex();
      setState(() {
        _currentTilePadding = EdgeInsets.zero;
      });
    };
  }

  TickerFuture _animateIndicatorToNearest(Offset pixelsPerSecond, double width) {
    final nearest = _internalIndex;
    final target = _animationValueToAlignment(nearest.toDouble());
    _internalAnimation = _internalAnimationController.drive(AlignmentTween(
      begin: _currentIndicatorAlignment,
      end: target,
    ));
    final unitsPerSecondX = pixelsPerSecond.dx / width;
    final unitsPerSecond = Offset(unitsPerSecondX, 0);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    return _internalAnimationController.animateWith(simulation);
  }

  void _updateControllerIndex() {
    _controller!.index = _internalIndex;
  }
}

class _Labels extends StatelessWidget {
  const _Labels({
    Key? key,
    this.callbackBuilder,
    required this.tabs,
    required this.currentIndex,
    required this.textStyle,
    required this.selectedTextStyle,
    this.radius = const Radius.circular(20),
    this.splashColor,
    this.splashHighlightColor,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 8),
  }) : super(key: key);

  final VoidCallback Function(int index)? callbackBuilder;
  final List<SegmentTab> tabs;
  final int currentIndex;
  final TextStyle textStyle;
  final TextStyle selectedTextStyle;
  final EdgeInsets tabPadding;
  final Radius radius;
  final Color? splashColor;
  final Color? splashHighlightColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          tabs.length,
          (index) {
            final tab = tabs[index];
            return Flexible(
              flex: tab.flex,
              child: InkWell(
                splashColor: tab.splashColor ?? splashColor,
                highlightColor:
                    tab.splashHighlightColor ?? splashHighlightColor,
                borderRadius: BorderRadius.all(radius),
                onTap: callbackBuilder?.call(index),
                child: Padding(
                  padding: tabPadding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (tab.iconPosition == IconPosition.left &&
                          tab.iconBuilder != null)
                        tab.iconBuilder!(
                            selectedTextStyle.color ?? tab.textColor),
                      Center(
                        child: AnimatedDefaultTextStyle(
                          duration: kTabScrollDuration,
                          curve: Curves.ease,
                          style: (index == currentIndex) ? selectedTextStyle : textStyle,
                          child: Text(
                            tab.label,
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      if (tab.iconPosition == IconPosition.right &&
                          tab.iconBuilder != null)
                        tab.iconBuilder!(
                            selectedTextStyle.color ?? tab.textColor),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SqueezeAnimated extends StatelessWidget {
  const _SqueezeAnimated({
    Key? key,
    required this.builder,
    required this.currentTilePadding,
    this.squeezeDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  final Widget Function(EdgeInsets) builder;
  final EdgeInsets currentTilePadding;
  final Duration squeezeDuration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<EdgeInsets>(
      curve: Curves.decelerate,
      tween: Tween(
        begin: EdgeInsets.zero,
        end: currentTilePadding,
      ),
      duration: squeezeDuration,
      builder: (context, padding, _) => Padding(
        padding: padding,
        child: builder.call(padding),
      ),
    );
  }
}

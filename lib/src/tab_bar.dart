import 'package:animated_segmented_tab_control/src/utils/double_range.dart';
import 'package:flutter/foundation.dart';
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
    super.key,
    required this.tabs,
    this.height = kTextTabBarHeight,
    this.controller,
    this.tabTextColor,
    this.textStyle,
    this.selectedTextStyle,
    this.selectedTabTextColor,
    this.squeezeIntensity = 1,
    this.squeezeDuration = const Duration(milliseconds: 500),
    this.indicatorPadding = EdgeInsets.zero,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.splashColor,
    this.splashHighlightColor,
    this.barDecoration = const BoxDecoration(
      color: Colors.grey,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    this.indicatorDecoration = const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  });

  /// Height of the widget.
  ///
  /// [preferredSize] returns this value.
  final double height;

  /// Selection options.
  final List<SegmentTab> tabs;

  /// Can be provided by [DefaultTabController].
  final TabController? controller;

  /// Style of all labels. Color will not be applied.
  final TextStyle? textStyle;

  /// Style of selected tab label. Color will not be applied.
  final TextStyle? selectedTextStyle;

  /// The color of the text beyond the indicator.
  final Color? tabTextColor;

  /// The color of the text inside the indicator.
  final Color? selectedTabTextColor;

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

  /// Splash color of options.
  final Color? splashColor;

  /// Splash highlight color of options.
  final Color? splashHighlightColor;

  /// Segmented control bar decoration
  final BoxDecoration? barDecoration;

  ///Indicator decoration
  final BoxDecoration? indicatorDecoration;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _SegmentedTabControl(
          tabs: tabs,
          height: height,
          maxWidth: constraints.maxWidth,
          controller: controller,
          tabTextColor: tabTextColor,
          textStyle: textStyle,
          selectedTextStyle: selectedTextStyle,
          selectedTabTextColor: selectedTabTextColor,
          squeezeIntensity: squeezeIntensity,
          squeezeDuration: squeezeDuration,
          indicatorPadding: indicatorPadding,
          tabPadding: tabPadding,
          splashColor: splashColor,
          splashHighlightColor: splashHighlightColor,
          barDecoration: barDecoration,
          indicatorDecoration: indicatorDecoration,
        );
      },
    );
  }
}

class _SegmentedTabControl extends StatefulWidget
    implements PreferredSizeWidget {
  const _SegmentedTabControl({
    super.key,
    required this.height,
    required this.tabs,
    required this.maxWidth,
    this.controller,
    this.tabTextColor,
    this.textStyle,
    this.selectedTextStyle,
    this.selectedTabTextColor,
    this.squeezeIntensity = 1,
    this.squeezeDuration = const Duration(milliseconds: 500),
    this.indicatorPadding = EdgeInsets.zero,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.splashColor,
    this.splashHighlightColor,
    this.barDecoration,
    this.indicatorDecoration,
  });

  final List<SegmentTab> tabs;
  final double height;
  final double maxWidth;
  final TabController? controller;
  final TextStyle? textStyle;
  final TextStyle? selectedTextStyle;
  final Color? tabTextColor;
  final Color? selectedTabTextColor;
  final double squeezeIntensity;
  final Duration squeezeDuration;
  final EdgeInsets indicatorPadding;
  final EdgeInsets tabPadding;
  final Color? splashColor;
  final Color? splashHighlightColor;
  final BoxDecoration? barDecoration;
  final BoxDecoration? indicatorDecoration;

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

  /// Cumulative width fractions of the tabs, in range 0..1.
  List<double> flexFactors = [];

  /// Indicator travel range of each tab, as a fraction of the available width.
  ///
  /// Stored as fractions rather than pixels so the ranges stay valid when the
  /// available width changes, e.g. on device rotation.
  List<DoubleRange> alignmentXRanges = [];

  bool get _controllerIsValid => _controller?.animation != null;

  int _internalIndex = 0;

  @override
  void initState() {
    super.initState();
    _internalAnimationController = AnimationController(vsync: this);
    _internalAnimationController.addListener(_handleInternalAnimationTick);
    _recalculateGeometry();
  }

  void _handleInternalAnimationTick() {
    setState(() {
      _currentIndicatorAlignment = _internalAnimation.value;
    });
  }

  @override
  void dispose() {
    if (_controllerIsValid) {
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    }
    _controller = null;
    _internalAnimationController.removeListener(_handleInternalAnimationTick);
    _internalAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _updateTabController();
    super.didChangeDependencies();
  }

  /// Recomputes everything derived from [_SegmentedTabControl.tabs].
  ///
  /// None of it depends on the available width, so a resize does not need it.
  void _recalculateGeometry() {
    _calculateTotalFlex();
    _calculateFlexFactors();
    _calculateTabIndicatorAlignmentRanges();
  }

  void _calculateTotalFlex() {
    _totalFlex =
        widget.tabs.fold(0, (previousValue, tab) => previousValue + tab.flex);
  }

  void _calculateFlexFactors() {
    flexFactors.clear();
    int collectedFlex = 0;
    for (int i = 0; i < widget.tabs.length; i++) {
      collectedFlex += widget.tabs[i].flex;
      flexFactors.add(collectedFlex / _totalFlex);
    }
  }

  @override
  void didUpdateWidget(_SegmentedTabControl oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(widget.tabs, oldWidget.tabs)) {
      _recalculateGeometry();

      if (_internalIndex > widget.tabs.length - 1) {
        _internalIndex = widget.tabs.length - 1;
      }

      // Stop the running animation first, otherwise its next tick overwrites
      // the alignment with a value derived from the previous geometry.
      _internalAnimationController.stop();
      _currentIndicatorAlignment =
          _animationValueToAlignment(_internalIndex.toDouble());
    }

    if (widget.controller != oldWidget.controller) {
      _updateTabController();
    }
  }

  void _updateTabController() {
    final TabController? newController =
        widget.controller ?? DefaultTabController.of(context);
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

    assert(
      newController == null || newController.length == widget.tabs.length,
      'The number of tabs (${widget.tabs.length}) must match the length of the '
      'TabController (${newController.length}).',
    );

    if (newController == _controller) {
      return;
    }

    if (_controllerIsValid) {
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    }

    _controller = newController;

    if (_controller != null) {
      _controller!.animation!.addListener(_handleTabControllerAnimationTick);
      _currentIndicatorAlignment =
          _animationValueToAlignment(_controller!.index.toDouble());
    }
  }

  void _handleTabControllerAnimationTick() {
    final currentValue = _controller!.animation!.value;
    _animateIndicatorTo(_animationValueToAlignment(currentValue));
  }

  /// Fills [alignmentXRanges] from the tab flexes alone.
  ///
  /// The asymmetric branch handles a next tab narrower than the current one, so
  /// the indicator's midpoint interpolation stays visually centred while it
  /// resizes.
  void _calculateTabIndicatorAlignmentRanges() {
    alignmentXRanges.clear();

    double computedWidthFraction = 0;
    double alignmentStartXFraction = 0;

    for (int index = 0; index < widget.tabs.length - 1; index++) {
      final tabWidthFraction = widget.tabs[index].flex / _totalFlex;
      final nextTabWidthFraction = widget.tabs[index + 1].flex / _totalFlex;

      if (nextTabWidthFraction >= tabWidthFraction) {
        final alignmentEndXFraction =
            computedWidthFraction + (tabWidthFraction / 2);
        alignmentXRanges
            .add(DoubleRange(alignmentStartXFraction, alignmentEndXFraction));
        alignmentStartXFraction = alignmentEndXFraction;
      } else {
        final controlPointFraction =
            computedWidthFraction + (nextTabWidthFraction / 2);
        alignmentXRanges
            .add(DoubleRange(alignmentStartXFraction, controlPointFraction));
        alignmentStartXFraction = computedWidthFraction +
            tabWidthFraction -
            (nextTabWidthFraction / 2);
      }

      computedWidthFraction += tabWidthFraction;
    }
    alignmentXRanges
        .add(DoubleRange(alignmentStartXFraction, computedWidthFraction));
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

  /// Returns the indicator's left edge as a fraction of the available width.
  double _calculateTarget(double reminder, int index) {
    final tabLeftXFraction = index > 0 ? flexFactors[index - 1] : 0.0;
    double target;
    if (reminder > 0) {
      target = tabLeftXFraction +
          ((reminder * 2) *
              (alignmentXRanges[index].endInclusive - tabLeftXFraction));
    } else {
      target = tabLeftXFraction +
          ((reminder * 2) * (tabLeftXFraction - alignmentXRanges[index].start));
    }

    return target;
  }

  /// Converts an indicator left edge in 0..1 fractions of the available width to
  /// an [Alignment] in range -1..1.
  Alignment _calculateAlignmentFromTarget(double positionFraction, int index) {
    final halfTabWidthFraction = (widget.tabs[index].flex / _totalFlex) / 2;

    final x = (positionFraction - 0.5 + halfTabWidthFraction) /
        (0.5 - halfTabWidthFraction);

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

    final textStyle =
        widget.textStyle ?? Theme.of(context).textTheme.bodyMedium!;

    final selectedTextStyle = widget.selectedTextStyle ?? textStyle;

    final selectedTabTextColor = currentTab.selectedTextColor ??
        widget.selectedTabTextColor ??
        Colors.white;

    final tabTextColor = currentTab.textColor ??
        widget.tabTextColor ??
        Colors.white.withOpacity(0.7);

    return DefaultTextStyle(
      style: widget.textStyle ?? DefaultTextStyle.of(context).style,
      child: LayoutBuilder(
        builder: (context, _) {
          final indicatorWidth =
              ((widget.maxWidth - widget.indicatorPadding.horizontal) /
                      _totalFlex) *
                  widget.tabs[_internalIndex].flex;

          return ClipRRect(
            borderRadius:
                widget.barDecoration?.borderRadius ?? BorderRadius.zero,
            child: SizedBox(
              height: widget.height,
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: kTabScrollDuration,
                    curve: Curves.ease,
                    decoration: _resolveBackground(
                      widget.barDecoration,
                      currentTab.backgroundColor,
                      currentTab.backgroundGradient,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: _Labels(
                        radius: widget.indicatorDecoration?.borderRadius,
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
                      onPanUpdate: _onPanUpdate(widget.maxWidth),
                      onPanEnd: _onPanEnd(widget.maxWidth),
                      child: Padding(
                        padding: widget.indicatorPadding,
                        child: _SqueezeAnimated(
                          currentTilePadding: _currentTilePadding,
                          squeezeDuration: widget.squeezeDuration,
                          builder: (_) => AnimatedContainer(
                            duration: kTabScrollDuration,
                            curve: Curves.ease,
                            width: indicatorWidth,
                            height: widget.height -
                                widget.indicatorPadding.vertical,
                            decoration: _resolveBackground(
                              widget.indicatorDecoration,
                              currentTab.color,
                              currentTab.gradient,
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
                        size: Size(
                          indicatorWidth,
                          widget.height -
                              widget.indicatorPadding.vertical -
                              squeezePadding.vertical,
                        ),
                        offset: Offset(
                          _xToPercentsCoefficient(_currentIndicatorAlignment) *
                              (widget.maxWidth - indicatorWidth),
                          0,
                        ),
                      ),
                      child: IgnorePointer(
                        child: ExcludeSemantics(
                          child: _Labels(
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Applies a tab's [tabColor] / [tabGradient] override to [base]'s background.
  ///
  /// Colour and gradient are resolved as a *pair*: if the tab specifies either
  /// one, it replaces both.
  BoxDecoration? _resolveBackground(
    BoxDecoration? base,
    Color? tabColor,
    Gradient? tabGradient,
  ) {
    if (tabColor == null && tabGradient == null) return base;

    final baseGradient = base?.gradient;

    final Gradient? gradient;
    if (tabGradient != null) {
      gradient = tabGradient;
    } else if (tabColor != null && baseGradient != null) {
      gradient = baseGradient is LinearGradient
          ? LinearGradient(
              begin: baseGradient.begin,
              end: baseGradient.end,
              transform: baseGradient.transform,
              colors: [tabColor, tabColor],
            )
          : LinearGradient(colors: [tabColor, tabColor]);
    } else {
      gradient = null;
    }

    final color = gradient == null ? tabColor : null;

    if (base == null) {
      return BoxDecoration(color: color, gradient: gradient);
    }

    return BoxDecoration(
      color: color,
      gradient: gradient,
      image: base.image,
      border: base.border,
      borderRadius: base.borderRadius,
      boxShadow: base.boxShadow,
      backgroundBlendMode: base.backgroundBlendMode,
      shape: base.shape,
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
        _currentTilePadding =
            EdgeInsets.symmetric(vertical: widget.squeezeIntensity);
      });
    };
  }

  GestureDragUpdateCallback? _onPanUpdate(double maxWidth) {
    if (_controller!.indexIsChanging) {
      return null;
    }
    return (details) {
      double x = _currentIndicatorAlignment.x +
          details.delta.dx / (maxWidth / widget.tabs.length);
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
    final roundedCurrentPosition =
        num.parse(currentPosition.toStringAsFixed(2));

    final index = flexFactors
        .indexWhere((flexFactor) => roundedCurrentPosition <= flexFactor);

    return index == -1 ? _controller!.length - 1 : index;
  }

  /// Converts [Alignment.x] value in range -1..1 to 0..1 percents coefficient
  double _xToPercentsCoefficient(Alignment alignment) {
    return (alignment.x + 1) / 2;
  }

  GestureDragEndCallback _onPanEnd(double maxWidth) {
    return (details) {
      _animateIndicatorToNearest(
        details.velocity.pixelsPerSecond,
        maxWidth,
      );
      _updateControllerIndex();
      setState(() {
        _currentTilePadding = EdgeInsets.zero;
      });
    };
  }

  TickerFuture _animateIndicatorToNearest(
      Offset pixelsPerSecond, double width) {
    final nearest = _internalIndex;
    final target = _animationValueToAlignment(nearest.toDouble());
    _internalAnimation = _internalAnimationController.drive(AlignmentTween(
      begin: _currentIndicatorAlignment,
      end: target,
    ));
    final unitsPerSecondX = pixelsPerSecond.dx / width;
    final unitsPerSecond = Offset(unitsPerSecondX, 0);
    final unitVelocity = unitsPerSecond.distance;

    const spring =
        SpringDescription(mass: 1, stiffness: 225.03305555555556, damping: 30);

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
    this.radius,
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
  final BorderRadiusGeometry? radius;
  final Color? splashColor;
  final Color? splashHighlightColor;

  @override
  Widget build(BuildContext context) {
    final callbackBuilder = this.callbackBuilder;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          tabs.length,
          (index) {
            final tab = tabs[index];

            final content = Padding(
              padding: tabPadding,
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: kTabScrollDuration,
                  curve: Curves.ease,
                  style:
                      (index == currentIndex) ? selectedTextStyle : textStyle,
                  child: Text(
                    tab.label,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );

            return Flexible(
              flex: tab.flex,
              child: callbackBuilder == null
                  ? content
                  : InkWell(
                      splashColor: tab.splashColor ?? splashColor,
                      highlightColor:
                          tab.splashHighlightColor ?? splashHighlightColor,
                      borderRadius: radius as BorderRadius?,
                      onTap: callbackBuilder(index),
                      child: content,
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

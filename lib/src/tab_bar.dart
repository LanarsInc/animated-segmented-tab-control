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

  /// Style of all labels. Color will not applied.
  final TextStyle? textStyle;

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
  }) : super(key: key);

  final double height;
  final List<SegmentTab> tabs;
  final TabController? controller;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final TextStyle? textStyle;
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

  int totalFlex = 0;

  double _maxWidth = 0;

  List<double> flexFactors = [];

  bool get _controllerIsValid => _controller?.animation != null;

  int get _internalIndex => _alignmentToIndex(_currentIndicatorAlignment);

  int _alignmentToIndex(Alignment alignment) {
    final currentPosition = _xToPercentsCoefficient(alignment);
    final roundedCurrentPosition = num.parse(currentPosition.toStringAsFixed(2));
    return flexFactors.indexWhere((element) => element >= roundedCurrentPosition);
  }

  /// Converts [Alignment.x] value in range -1..1 to 0..1 percents coefficient
  double _xToPercentsCoefficient(Alignment alignment) {
    return (alignment.x + 1) / 2;
  }

  @override
  void initState() {
    super.initState();
    _maxWidth = widget.maxWidth;
    _internalAnimationController = AnimationController(vsync: this);
    _internalAnimationController.addListener(_handleInternalAnimationTick);
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
    _calculateTotalFlex();
    _calculateFlexFactors();
    _updateTabController();
    super.didChangeDependencies();
  }

  void _calculateTotalFlex() {
    totalFlex = widget.tabs.fold(0, (previousValue, tab) => previousValue + tab.flex);
  }

  void _calculateFlexFactors() {
    int collectedFlex = 0;
    for (int i = 0; i < widget.tabs.length; i++) {
      collectedFlex += widget.tabs[i].flex;
      flexFactors.add(collectedFlex / totalFlex);
    }
  }

  @override
  void didUpdateWidget(_SegmentedTabControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
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
    if (_controller != null) {
      _controller!.animation!.addListener(_handleTabControllerAnimationTick);
      _currentIndicatorAlignment = _animationValueToAlignment(_controller!.index.toDouble());
    }
  }

  void _handleTabControllerAnimationTick() {
    final currentValue = _controller!.animation!.value;
    _animateIndicatorTo(_animationValueToAlignment(currentValue));
  }

  Alignment _animationValueToAlignment(double? value) {
    if (value == null) {
      return const Alignment(-1, 0);
    }

    final index = _animationValueToTabIndex(value);

    return _calculateAlignmentFromTabIndex(index);
  }

  int _animationValueToTabIndex(double value) {
    final lastTabIndex = _controller!.length - 1;
    final inPercents = value / lastTabIndex;
    final oneTabInPercents = 1 / _controller!.length;
    final index = inPercents >= 1 ? lastTabIndex : (inPercents / oneTabInPercents).floor();

    return index;
  }

  Alignment _calculateAlignmentFromTabIndex(int index) {
    double tabWidth;
    double tabLeftX;

    if (index > 0) {
      tabWidth = (flexFactors[index] - flexFactors[index - 1]) * _maxWidth;
      tabLeftX = _maxWidth * flexFactors[index - 1];
    } else {
      tabWidth = flexFactors[0] * _maxWidth;
      tabLeftX = 0;
    }

    final currentTabHalfWidth = tabWidth / 2;
    final halfMaxWidth = _maxWidth / 2;

    final x =
        (tabLeftX - halfMaxWidth + currentTabHalfWidth) / (halfMaxWidth - currentTabHalfWidth);

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
            ((constraints.maxWidth - widget.indicatorPadding.horizontal) / totalFlex) *
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
      });
    };
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
    this.radius = const Radius.circular(20),
    this.splashColor,
    this.splashHighlightColor,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 8),
  }) : super(key: key);

  final VoidCallback Function(int index)? callbackBuilder;
  final List<SegmentTab> tabs;
  final int currentIndex;
  final TextStyle textStyle;
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
                highlightColor: tab.splashHighlightColor ?? splashHighlightColor,
                borderRadius: BorderRadius.all(radius),
                onTap: callbackBuilder?.call(index),
                child: Padding(
                  padding: tabPadding,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: kTabScrollDuration,
                      curve: Curves.ease,
                      style: textStyle,
                      child: Text(
                        tab.label,
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
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

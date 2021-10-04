library customizable_tab_bar;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'utils/custom_clippers.dart';

part 'customizable_tab.dart';

class CustomizableTabBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomizableTabBar({
    Key? key,
    this.height = 46,
    required this.tabs,
    this.controller,
    this.backgroundColor,
    this.tabTextColor,
    this.textStyle,
    this.selectedTabTextColor,
    this.indicatorColor,
    this.squeezeIntensity = 1,
    this.squeezeDuration = const Duration(milliseconds: 500),
    this.squeezeCurve = Curves.decelerate,
    this.indicatorPadding = EdgeInsets.zero,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.radius = const Radius.circular(20),
    this.splashColor,
    this.splashHighlightColor,
  })  : borderRadius = const BorderRadius.all(Radius.circular(20)),
        super(key: key);

  final double height;
  final List<CustomizableTab> tabs;
  final TabController? controller;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final Color? tabTextColor;
  final Color? selectedTabTextColor;
  final Color? indicatorColor;
  final double squeezeIntensity;
  final Duration squeezeDuration;
  final Curve squeezeCurve;
  final EdgeInsets indicatorPadding;
  final EdgeInsets tabPadding;
  final BorderRadius borderRadius;
  final Radius radius;
  final Color? splashColor;
  final Color? splashHighlightColor;

  @override
  _CustomizableTabBarState createState() => _CustomizableTabBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _CustomizableTabBarState extends State<CustomizableTabBar>
    with SingleTickerProviderStateMixin {
  EdgeInsets _currentTilePadding = EdgeInsets.zero;
  Alignment _currentIndicatorAlignment = Alignment.centerLeft;
  late AnimationController _internalAnimationController;
  late Animation<Alignment> _internalAnimation;
  TabController? _controller;

  @override
  void initState() {
    super.initState();
    _internalAnimationController = AnimationController(vsync: this);
    _internalAnimationController.addListener(_handleInternalAnimationTick);
  }

  @override
  void dispose() {
    _internalAnimationController.removeListener(_handleInternalAnimationTick);
    _internalAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
  }

  @override
  void didUpdateWidget(CustomizableTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateTabController();
    }
  }

  bool get _controllerIsValid => _controller?.animation != null;

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

    if (newController == _controller) {
      return;
    }

    if (_controllerIsValid) {
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    }
    _controller = newController;
    if (_controller != null) {
      _controller!.animation!.addListener(_handleTabControllerAnimationTick);
    }
  }

  void _handleInternalAnimationTick() {
    setState(() {
      _currentIndicatorAlignment = _internalAnimation.value;
    });
  }

  void _handleTabControllerAnimationTick() {
    final currentValue = _controller!.animation!.value;
    _animateIndicatorTo(_animationValueToAlignment(currentValue));
  }

  void _updateControllerIndex() {
    _controller!.index = _alignmentToIndex(_currentIndicatorAlignment);
  }

  TickerFuture _animateIndicatorToNearest(
      Offset pixelsPerSecond, double width) {
    final nearest = _alignmentToIndex(_currentIndicatorAlignment);
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

  TickerFuture _animateIndicatorTo(Alignment target) {
    _internalAnimation = _internalAnimationController.drive(AlignmentTween(
      begin: _currentIndicatorAlignment,
      end: target,
    ));

    return _internalAnimationController.fling();
  }

  Alignment _animationValueToAlignment(double? value) {
    if (value == null) {
      return const Alignment(-1, 0);
    }
    final x = value / (_controller!.length - 1) * 2 - 1;
    return Alignment(x, 0);
  }

  int _alignmentToIndex(Alignment alignment) {
    final currentPosition =
        (_controller!.length - 1) * _convertXToCoef(alignment);
    return currentPosition.round();
  }

  double _convertXToCoef(Alignment alignment) {
    return (alignment.x + 1) / 2;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: widget.textStyle ?? DefaultTextStyle.of(context).style,
      child: LayoutBuilder(builder: (context, constraints) {
        final currentTab =
            widget.tabs[_alignmentToIndex(_currentIndicatorAlignment)];
        final indicatorWidth =
            (constraints.maxWidth - widget.indicatorPadding.horizontal) /
                _controller!.length;
        return ClipRRect(
          borderRadius: widget.borderRadius,
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: kTabScrollDuration,
                  curve: Curves.ease,
                  decoration: BoxDecoration(
                    color: currentTab.selectedBackgroundColor ??
                        widget.backgroundColor ??
                        Theme.of(context).colorScheme.background,
                    borderRadius: widget.borderRadius,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: DefaultTextStyle.merge(
                      style: (widget.textStyle ??
                              DefaultTextStyle.of(context).style)
                          .copyWith(
                              color: currentTab.unselectedTextColor ??
                                  widget.tabTextColor ??
                                  Theme.of(context).colorScheme.onBackground),
                      child: _buildTabLabels(constraints.maxWidth),
                    ),
                  ),
                ),
                Align(
                  alignment: _currentIndicatorAlignment,
                  child: GestureDetector(
                    onPanDown: (details) {
                      _internalAnimationController.stop();
                      setState(() {
                        _currentTilePadding = EdgeInsets.symmetric(
                            vertical: widget.squeezeIntensity);
                      });
                    },
                    onPanUpdate: (details) {
                      double x = _currentIndicatorAlignment.x +
                          details.delta.dx / (constraints.maxWidth / 2);
                      if (x < -1) {
                        x = -1;
                      } else if (x > 1) {
                        x = 1;
                      }
                      setState(() {
                        _currentIndicatorAlignment = Alignment(x, 0);
                      });
                    },
                    onPanEnd: (details) {
                      _animateIndicatorToNearest(
                        details.velocity.pixelsPerSecond,
                        constraints.maxWidth,
                      );
                      _updateControllerIndex();
                      setState(() {
                        _currentTilePadding = EdgeInsets.zero;
                      });
                    },
                    child: _squeezeAnimated((_) => AnimatedContainer(
                          duration: kTabScrollDuration,
                          curve: Curves.ease,
                          width: indicatorWidth,
                          height:
                              widget.height - widget.indicatorPadding.vertical,
                          decoration: BoxDecoration(
                            color: currentTab.selectedColor ??
                                widget.indicatorColor ??
                                Theme.of(context).indicatorColor,
                            borderRadius: widget.borderRadius,
                          ),
                        )),
                  ),
                ),
                _squeezeAnimated((squeezePadding) => ClipPath(
                      clipper: RRectRevealClipper(
                        radius: widget.radius,
                        size: Size(
                          indicatorWidth,
                          widget.height -
                              widget.indicatorPadding.vertical -
                              squeezePadding.vertical,
                        ),
                        offset: Offset(
                            _convertXToCoef(_currentIndicatorAlignment) *
                                (constraints.maxWidth - indicatorWidth),
                            0),
                      ),
                      child: DefaultTextStyle.merge(
                        style: DefaultTextStyle.of(context).style.copyWith(
                            color: widget.selectedTabTextColor ??
                                Theme.of(context).colorScheme.onSecondary),
                        child: IgnorePointer(
                          child: _buildTabLabels(constraints.maxWidth, true),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTabLabels(double availableSpace, [bool selectedTabs = false]) {
    final width = availableSpace / _controller!.length;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          widget.tabs.length,
          (index) {
            final tab = widget.tabs[index];
            return SizedBox(
              width: width,
              child: InkWell(
                splashColor: tab.splashColor ?? widget.splashColor,
                highlightColor:
                    tab.splashHighlightColor ?? widget.splashHighlightColor,
                borderRadius: widget.borderRadius,
                onTap: () {
                  _internalAnimationController.stop();
                  _controller!.animateTo(index);
                },
                child: Padding(
                  padding: widget.tabPadding,
                  child: Center(
                    child: Text(
                      tab.label,
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                      style: (widget.textStyle ??
                              Theme.of(context).textTheme.bodyText2!)
                          .copyWith(
                        color: selectedTabs
                            ? tab.selectedTextColor ??
                                widget.selectedTabTextColor ??
                                Colors.white
                            : tab.unselectedTextColor ??
                                widget.tabTextColor ??
                                Colors.white.withOpacity(0.7),
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

  Widget _squeezeAnimated(Widget Function(EdgeInsets) builder) {
    return TweenAnimationBuilder<EdgeInsets>(
      curve: widget.squeezeCurve,
      tween: Tween(
        begin: EdgeInsets.zero,
        end: _currentTilePadding,
      ),
      duration: widget.squeezeDuration,
      builder: (context, padding, _) => Padding(
        padding: padding,
        child: builder.call(padding),
      ),
    );
  }
}

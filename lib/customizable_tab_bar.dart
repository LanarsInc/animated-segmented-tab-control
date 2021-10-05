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
    this.indicatorPadding = EdgeInsets.zero,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.radius = const Radius.circular(20),
    this.splashColor,
    this.splashHighlightColor,
  }) : super(key: key);

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
  final EdgeInsets indicatorPadding;
  final EdgeInsets tabPadding;
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
    _controller!.index = _internalIndex;
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

  int get _internalIndex => _alignmentToIndex(_currentIndicatorAlignment);
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
    final currentTab = widget.tabs[_internalIndex];

    final textStyle =
        widget.textStyle ?? Theme.of(context).textTheme.bodyText2!;

    final selectedTabTextColor = currentTab.selectedTextColor ??
        widget.selectedTabTextColor ??
        Colors.white;

    final tabTextColor = currentTab.textColor ??
        widget.tabTextColor ??
        Colors.white.withOpacity(0.7);

    final backgroundColor = currentTab.backgroundColor ??
        widget.backgroundColor ??
        Theme.of(context).colorScheme.background;

    final indicatorColor = currentTab.color ??
        widget.indicatorColor ??
        Theme.of(context).indicatorColor;

    final borderRadius = BorderRadius.all(widget.radius);

    return DefaultTextStyle(
      style: widget.textStyle ?? DefaultTextStyle.of(context).style,
      child: LayoutBuilder(builder: (context, constraints) {
        final indicatorWidth =
            (constraints.maxWidth - widget.indicatorPadding.horizontal) /
                _controller!.length;

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
                    borderRadius: borderRadius,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: _Labels(
                      radius: widget.radius,
                      splashColor: widget.splashColor,
                      splashHighlightColor: widget.splashHighlightColor,
                      callbackBuilder: _onTabTap(),
                      availableSpace: constraints.maxWidth,
                      tabs: widget.tabs,
                      currentIndex: _internalIndex,
                      textStyle: textStyle.copyWith(
                        color: tabTextColor,
                      ),
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
                        height:
                            widget.height - widget.indicatorPadding.vertical,
                        decoration: BoxDecoration(
                          color: indicatorColor,
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
                        widget.height -
                            widget.indicatorPadding.vertical -
                            squeezePadding.vertical,
                      ),
                      offset: Offset(
                        _convertXToCoef(_currentIndicatorAlignment) *
                            (constraints.maxWidth - indicatorWidth),
                        0,
                      ),
                    ),
                    child: IgnorePointer(
                      child: _Labels(
                        radius: widget.radius,
                        splashColor: widget.splashColor,
                        splashHighlightColor: widget.splashHighlightColor,
                        availableSpace: constraints.maxWidth,
                        tabs: widget.tabs,
                        currentIndex: _internalIndex,
                        textStyle: textStyle.copyWith(
                          color: selectedTabTextColor,
                        ),
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
        _currentTilePadding =
            EdgeInsets.symmetric(vertical: widget.squeezeIntensity);
      });
    };
  }

  GestureDragUpdateCallback? _onPanUpdate(BoxConstraints constraints) {
    if (_controller!.indexIsChanging) {
      return null;
    }
    return (details) {
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
}

class _Labels extends StatelessWidget {
  _Labels({
    Key? key,
    this.callbackBuilder,
    required this.availableSpace,
    required this.tabs,
    required this.currentIndex,
    required this.textStyle,
    this.radius = const Radius.circular(20),
    this.splashColor,
    this.splashHighlightColor,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 8),
  }) : super(key: key);

  final VoidCallback Function(int index)? callbackBuilder;
  final double availableSpace;
  final List<CustomizableTab> tabs;
  final int currentIndex;
  final TextStyle textStyle;
  final EdgeInsets tabPadding;
  final Radius radius;
  final Color? splashColor;
  final Color? splashHighlightColor;

  late final width = availableSpace / tabs.length;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          tabs.length,
          (index) {
            final tab = tabs[index];
            return SizedBox(
              width: width,
              child: InkWell(
                splashColor: tab.splashColor ?? splashColor,
                highlightColor:
                    tab.splashHighlightColor ?? splashHighlightColor,
                borderRadius: BorderRadius.all(radius),
                onTap: callbackBuilder?.call(index),
                child: Padding(
                  padding: tabPadding,
                  child: Center(
                    child: Text(
                      tab.label,
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                      style: textStyle,
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

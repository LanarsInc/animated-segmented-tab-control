## 2.1.0
* Enhancement: Add `SegmentTab.labelBuilder` to display custom tab content, such as an icon
  ([#32](https://github.com/LanarsInc/animated-segmented-tab-control/issues/32)), based on the approach
  proposed by [YoungmanCH](https://github.com/YoungmanCH) with the color-passing idea
  from [Thientran2910](https://github.com/Thientran2910)
* Enhancement: Add right-to-left layout support, based on the approach proposed
  by [melek-hedhili](https://github.com/melek-hedhili)
* Fix [#39](https://github.com/LanarsInc/animated-segmented-tab-control/issues/39): Update indicator geometry
  when the widget width or tab count changes
* Fix [#31](https://github.com/LanarsInc/animated-segmented-tab-control/issues/31):
  `AnimationController.stop()` called after `AnimationController.dispose()`
* Fix tab-level color and gradient overrides being ignored when resolving bar and indicator decorations
* Fix duplicate semantics and unreachable ink wells in the label overlay
* Fix stale API references in documentation

## 2.0.1
* Fix indicator getting stuck after releasing a slow drag on the selected tab (Flutter >= 3.32.0)

## 2.0.0
* **Breaking changes**
    * `SegmentedTabControl.backgroundColor` and `SegmentedTabControl.backgroundGradient` params replaced with `barDecoration` so you gain more
      customisation;
    *
    * `SegmentedTabControl.indicatorColor` and `SegmentedTabControl.indicatorGradient` params replaced with `indicatorDecoration`;
    * `SegmentedTabControl.radius` param was deleted. Now you could set border radius separately for `bar` and `indicator`
      using decorations;
    * the default `SegmentedTabControl.height` is equal to `kTextTabBarHeight` now. 48.0.
* Fix indicator drag behaviour

## 1.2.1
* Enhancement: Add `selectedTextStyle` parameter

## 1.2.0
* Enhancement: Add possibility to set different sizes of tabs (`flex`)
* Fix indicator padding

## 1.1.0
* Enhancement: Add background and indicator gradient support
  by [CodeEagle](https://github.com/CodeEagle)
* Bugfix [#15](https://github.com/LanarsInc/animated-segmented-tab-control/issues/15) Indicator
  initial position
* Fix tab bar padding by [phantoms158](https://github.com/phantoms158)

## 1.0.1
* Minor fixes.

## 1.0.0
* Added documentation.
* Updated example with pub.dev rules.
* Initial stable release.

## 0.0.1
Initial release

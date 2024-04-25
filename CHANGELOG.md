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

<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A customizable segment tab control. Can be used with or without TabView.

## Features

The package provides an advanced segmented control widget based on the `TabController`.

![screen-20211007-171939_2](https://user-images.githubusercontent.com/92156712/136547187-fb7eb419-3f18-419f-9ca1-8d25d85b9a44.gif)
![screen-20211007-170003_2](https://user-images.githubusercontent.com/92156712/136547191-3fd7ac95-0153-4fad-83d8-e356d7133273.gif)

## Getting started

To use the package, add the dependency to the `pubspec.yaml` file.

```
dependencies:
  ...
  animated_segmented_tab_control: any
```

And import the library.

```dart
import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
```

## Usage

The package contains a `SegmentedTabControl` widget that requires a `SegmentTab` list.

```dart
SegmentedTabControl(
  tabs: [
    SegmentTab(
      label: "Home".
    ),
  ],
)
```

SegmentedTabControl also requires a TabController. You can provide it with a `DefaultTabController` or instantiate a `TabController` instead.

```dart
DefaultTabController(
  length: 2,
  SegmentedTabControl(
    tabs: [
      SegmentTab(
        label: "Home",
      ),
      SegmentTab(
        label: "Account",
      ),
    ],
  )
)
```

You can change the entire widget or an individual tab. Or combine it. All provided values in the `SegmentedTabControl` will be replaced with values from each tab.

```dart
SegmentedTabControl(
  backgroundColor: Colors.grey.shade300,
  indicatorColor: Colors.orange.shade200,
  tabTextColor: Colors.black45,
  selectedTabTextColor: Colors.white,
  tabs: [
    SegmentTab(
      label: 'ACCOUNT',
      color: Colors.red.shade200,
    ),
    SegmentTab(
      label: 'HOME',
      backgroundColor: Colors.blue.shade100,
      selectedTextColor: Colors.black45,
      textColor: Colors.black26,
    ),
    const SegmentTab(label: 'NEW'),
  ],
),
```

Change tracking logic is identical to TabBar logic.

```dart
DefaultTabController.of(context).index
```

or

```dart
_controller.index
```

You can find more examples here: https://github.com/LanarsInc/animated-segmented-tab-control/example

## Additional information

If you have any ideas or are running into a bug, please submit an issue on github page: https://github.com/LanarsInc/animated-segmented-tab-control/issues

import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final selectedTextStyle = textStyle?.copyWith(fontWeight: FontWeight.bold);
    return MaterialApp(
      // Provides the [TabController]
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SegmentedTabControl(
                    // Customization of widget
                    tabTextColor: Colors.black,
                    selectedTabTextColor: Colors.white,
                    indicatorPadding: const EdgeInsets.all(4),
                    squeezeIntensity: 2,
                    tabPadding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: textStyle,
                    selectedTextStyle: selectedTextStyle,
                    // Options for selection
                    // All specified values will override the [SegmentedTabControl] setting
                    tabs: [
                      SegmentTab(
                        label: 'ACCOUNT',
                        // For example, this overrides [indicatorColor] from [SegmentedTabControl]
                        color: Colors.red.shade300,
                        backgroundColor: Colors.red.shade100,
                      ),
                      SegmentTab(
                        label: 'HOME',
                        backgroundColor: Colors.blue.shade100,
                        color: Colors.blue.shade300,
                      ),
                      SegmentTab(
                        label: 'NEW',
                        backgroundColor: Colors.orange.shade100,
                        color: Colors.orange.shade300,
                      ),
                    ],
                  ),
                ),
                // Sample pages
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      SampleWidget(
                        label: 'FIRST PAGE',
                        color: Colors.red.shade100,
                      ),
                      SampleWidget(
                        label: 'SECOND PAGE',
                        color: Colors.blue.shade100,
                      ),
                      SampleWidget(
                        label: 'THIRD PAGE',
                        color: Colors.orange.shade100,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SampleWidget extends StatelessWidget {
  const SampleWidget({
    Key? key,
    required this.label,
    required this.color,
  }) : super(key: key);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Text(label),
    );
  }
}

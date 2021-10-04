import 'package:customizable_tab_bar/customizable_tab_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomizableTabBar(
                    backgroundColor: Colors.indigoAccent,
                    indicatorColor: Colors.indigo,
                    tabTextColor: Colors.white.withOpacity(0.5),
                    selectedTabTextColor: Colors.white,
                    squeezeIntensity: 2,
                    height: 30,
                    tabPadding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: Theme.of(context).textTheme.caption,
                    tabs: [
                      CustomizableTab(
                        label: 'ACCOUNT',
                        selectedBackgroundColor: Colors.blueGrey,
                        selectedColor: Colors.blueGrey.shade200,
                      ),
                      const CustomizableTab(
                        label: 'HOME',
                        selectedBackgroundColor: Colors.redAccent,
                        selectedColor: Colors.red,
                      ),
                      const CustomizableTab(label: 'NEW'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Container(
                        alignment: Alignment.center,
                        color: Colors.blueGrey.withOpacity(0.5),
                        child: const Text('1'),
                      ),
                      Container(
                        alignment: Alignment.center,
                        color: Colors.red.withOpacity(0.5),
                        child: const Text('2'),
                      ),
                      Container(
                        alignment: Alignment.center,
                        color: Colors.blue.withOpacity(0.5),
                        child: const Text('3'),
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

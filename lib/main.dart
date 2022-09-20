import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        canvasColor: Colors.white,
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _tabNavigator = GlobalKey<TabNavigatorState>();
  final _tab1 = GlobalKey<NavigatorState>();
  final _tab2 = GlobalKey<NavigatorState>();
  final _tab3 = GlobalKey<NavigatorState>();

  var _tabSelectedIndex = 0;
  var _tabPopStack = false;

  void _setIndex(index) {

    setState(() {
      _tabPopStack = _tabSelectedIndex == index;
      _tabSelectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _tabNavigator.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          // if not on the 'main' tab
          if (_tabSelectedIndex != 0) {
            // select 'main' tab
            _setIndex(0);
            // back button handled by app
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },

      // onWillPop: () async => !await _tabNavigator.currentState!.maybePop(),
      child: Scaffold(
        body: TabNavigator(
          key: _tabNavigator,
          tabs: <TabItem>[
            TabItem(_tab1, Page1()),
            // TabItem(_tab1, PageWithButton(title: 'Audio')),
            TabItem(_tab2, PageWithButton(title: 'Video')),
            TabItem(_tab3, PageWithButton(title: 'More')),
          ],
          selectedIndex: _tabSelectedIndex,
          popStack: _tabPopStack,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tabSelectedIndex,
          onTap: _setIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.audiotrack),
              label: 'Audio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.ondemand_video),
              label: 'Video',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}

class PageWithButton extends StatelessWidget {
  final String title;
  final int count;

  const PageWithButton({
    Key? key,
    required this.title,
    this.count = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Center(
        child: RaisedButton(
          child: Text("$title $count"),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PageWithButton(title: title, count: count + 1),
            ));
          },
        ),
      ),
    );
  }
}

class TabItem {
  final GlobalKey<NavigatorState> key;
  final Widget tab;

  const TabItem(this.key, this.tab);
}

class TabNavigator extends StatefulWidget {
  final List<TabItem> tabs;
  final int selectedIndex;
  final bool popStack;

  TabNavigator({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    this.popStack = false,
  }) : super(key: key);

  @override
  TabNavigatorState createState() => TabNavigatorState();
}

class TabNavigatorState extends State<TabNavigator> {
  ///
  /// Try to pop widget, return true if popped
  ///
  Future<bool> maybePop() {
    return widget.tabs[widget.selectedIndex].key.currentState!.maybePop();
  }

  _popStackIfRequired(BuildContext context) async {
    if (widget.popStack) {
      widget.tabs[widget.selectedIndex].key.currentState!
          .popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('selectedIndex=${widget.selectedIndex}, popStack=${widget.popStack}');

    _popStackIfRequired(context);

    return Stack(
      children: List.generate(widget.tabs.length, _buildTab),
    );
  }

  Widget _buildTab(int index) {
    return Offstage(
      offstage: widget.selectedIndex != index,
      child: Opacity(
        opacity: widget.selectedIndex == index ? 1.0 : 0.0,
        child: Navigator(
          key: widget.tabs[index].key,
          onGenerateRoute: (settings) => MaterialPageRoute(
            settings: settings,
            builder: (_) => widget.tabs[index].tab,
          ),
        ),
      ),
    );
  }
}

class Page1 extends StatefulWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      child: CupertinoButton(
        child: Text('click'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Page2(),
            ),
          );
        },
      ),
    );
  }
}

class Page2 extends StatefulWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lucra/main.dart';
import 'package:lucra/models/balance.dart';
import 'package:lucra/models/demo_balances.dart';
import 'package:lucra/providers/balance_groups.dart';
import 'package:lucra/screens/balances.dart';
import 'package:lucra/screens/options.dart';
import 'package:lucra/screens/resume.dart';
import 'package:lucra/services/shop.dart';
import 'package:lucra/tour_target.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  static int _index = 1;
  // steps
  late TutorialCoachMark tutorialCoachMark;
  GlobalKey navigationBalances = GlobalKey();
  GlobalKey incomeCard = GlobalKey();
  late MotionTabBarController _motionTabBarController;

  @override
  void initState() {
    super.initState();
    _motionTabBarController = MotionTabBarController(
      initialIndex: _index,
      length: 3,
      vsync: this,
    );
    _motionTabBarController.addListener(_handleTabSelection);
    shop.getProduct(context);
    init();
    // Another showcase method
    // steps
    createTutorial();
    // method 2
    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) => ShowCaseWidget.of(context).startShowCase([incomeCard]),
    // );
  }

  @override
  void dispose() {
    super.dispose();
    _motionTabBarController.dispose();
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: landingPageTargets(
        navigationBalances: navigationBalances,
        incomeCard: incomeCard,
      ),
      colorShadow: Colors.blue,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onClickTarget: (target) {
        // Check if the clicked target is the one you want to perform a specific action for
        if (target.identify == "incomeCard") {
          // Perform custom logic specific to the incomeCard target
          (target.identify as Function).call();
          print("Clicked on incomeCard target!");
          // Add your action here...
        }
      },
    );
    tutorialCoachMark.show(context: context);
  }

  init() async {
    await loadExamples();
  }

  loadExamples() async {
    // await prefs.clear(); // TEST
    if (initialRoute == '/slides') {
      await Provider.of<BalanceGroups>(context, listen: false).deleteBalances();
      // ignore: use_build_context_synchronously
      await Provider.of<BalanceGroups>(context, listen: false)
          .addBalances(demoBalanceGroups);
    } else {
      await Provider.of<BalanceGroups>(context, listen: false)
          .getBalanceGroups();
    }
  }

  _handleTabSelection() {
    setState(() {
      _index = _motionTabBarController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // _motionTabBarController = TabController(
    //   vsync: this,
    //   initialIndex: _index, // avoid error when we log out
    //   length: 3,
    // );
    return tabs();
  }

  Widget tabs() {
    return Scaffold(
      body: NotificationListener(
        child: TabBarView(
          controller: _motionTabBarController,
          children: <Widget>[
            const OptionsScreen(),
            BalancesScreen(incomeCardKey: incomeCard),
            ResumeScreen(
              balance: Balance(
                id: "",
                title: "",
                balance: 0,
                fromDate: DateTime.now().toString(),
                timesAYear: 1,
                image: '',
              ),
              global: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: navigationBar(),
    );
  }

  Widget navigationBar() {
    // return Text(key: navigationBalances, 'TESTING2');
    return MotionTabBar(
      controller: _motionTabBarController,
      initialSelectedTab: translate('balances'),
      labels: [translate('options'), translate('balances'), translate('total')],
      icons: const [LineIcons.cog, LineIcons.list, LineIcons.coins],
      // optional badges, length must be same with labels
      tabSize: 50,
      tabBarHeight: 55,
      textStyle: const TextStyle(
        fontSize: 12,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      tabIconColor: Colors.blue[600],
      tabIconSize: 28.0,
      tabIconSelectedSize: 26.0,
      tabSelectedColor: Colors.blue[900],
      tabIconSelectedColor: Colors.white,
      tabBarColor: Colors.white,
      onTabItemSelected: (int value) {
        setState(() {
          // _tabController!.index = value;
          _motionTabBarController.index = value;
        });
      },
    );
    // return SnakeNavigationBar.color(
    //   // behaviour: snakeBarStyle,
    //   // snakeShape: snakeShape,
    //   // shape: bottomBarShape,
    //   // padding: padding,

    //   ///configuration for SnakeNavigationBar.color
    //   // snakeViewColor: selectedColor,
    //   // selectedItemColor:
    //   //     snakeShape == SnakeShape.indicator ? selectedColor : null,
    //   unselectedItemColor: Colors.blueGrey,

    //   ///configuration for SnakeNavigationBar.gradient
    //   //snakeViewGradient: selectedGradient,
    //   //selectedItemGradient: snakeShape == SnakeShape.indicator ? selectedGradient : null,
    //   //unselectedItemGradient: unselectedGradient,

    //   showUnselectedLabels: false,
    //   showSelectedLabels: true,

    //   currentIndex: _index,
    //   onTap: (index) => setState(() => _index = index),
    //   items: [
    //     BottomNavigationBarItem(
    //         icon: Icon(Icons.notifications), label: 'tickets'),
    //     BottomNavigationBarItem(
    //         icon: Icon(LineIcons.calendar), label: 'calendar'),
    //     BottomNavigationBarItem(icon: Icon(LineIcons.home), label: 'home'),
    //     BottomNavigationBarItem(
    //         icon: Icon(LineIcons.acquisitionsIncorporated), label: 'microphone'),
    //     BottomNavigationBarItem(icon: Icon(LineIcons.search), label: 'search')
    //   ],
    // );
  }
}

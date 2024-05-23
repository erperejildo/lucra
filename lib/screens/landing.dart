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
import 'package:lucra/tour_target.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late TabController _leaseTabController;
  static int _index = 1;
  // steps
  late TutorialCoachMark tutorialCoachMark;
  GlobalKey navigationBalances = GlobalKey();
  GlobalKey incomeCard = GlobalKey();

  @override
  void initState() {
    super.initState();
    init();
    // Another showcase method
    // steps
    // createTutorial();
    // Future.delayed(Duration.zero, showTutorial);
    // method 2
    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) => ShowCaseWidget.of(context)
    //       .startShowCase([navigationBalances, incomeCard]),
    // );
  }

  @override
  void dispose() {
    _leaseTabController.dispose();
    super.dispose();
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      // targets: _createTargets(),
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
      _index = _leaseTabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _leaseTabController = TabController(
      vsync: this,
      initialIndex: _index, // avoid error when we log out
      length: 3,
    );
    _leaseTabController.addListener(_handleTabSelection);

    return tabs();
  }

  Widget tabs() {
    return Scaffold(
      body: SafeArea(
        child: NotificationListener(
          child: TabBarView(
            controller: _leaseTabController,
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
                ),
                global: true,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        color: Theme.of(context).primaryColor,
        child: TabBar(
          isScrollable: true,
          controller: _leaseTabController,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 5.0,
              color: Colors.white,
            ),
          ),
          tabs: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Tab(
                child: Icon(LineIcons.cog, color: Colors.white),
              ),
            ),
            // TODO: find another package
            // Showcase(
            //   key: navigationBalances,
            //   description:
            //       'This is your balances page. In here, you will find different expenses and incomes.',
            //   onBarrierClick: () => debugPrint('Barrier clicked'),
            //   child:
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(LineIcons.list, color: Colors.white),
                    Container(width: 10),
                    Text(
                      translate('balances'),
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(LineIcons.coins, color: Colors.white),
                    Container(width: 10),
                    Text(
                      translate('total'),
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lucra/helpers/helpers.dart';
import 'package:lucra/locales.dart';
import 'package:lucra/providers/ads.dart';
import 'package:lucra/providers/balance_groups.dart';
import 'package:lucra/route_generator.dart';
import 'package:lucra/screens/landing.dart';
import 'package:lucra/services/shop.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import 'models/demo_balances.dart';

String initialRoute = '/';
late SharedPreferences prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  await detectFirstTime();

  final delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en',
    supportedLocales: languages,
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<BalanceGroups>(create: (_) => BalanceGroups()),
      ChangeNotifierProvider<Ads>(create: (_) => Ads()),
    ],
    child: LocalizedApp(
      delegate,
      const MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
    changeStatusBar();
    shop.getProduct(context);
    loadExamples();
  }

  Future<void> loadExamples() async {
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

  void changeStatusBar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizationDelegate = LocalizedApp.of(context).delegate;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lucra',
      locale: Helpers.getSavedLanguage(context),
      supportedLocales: localizationDelegate.supportedLocales,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        localizationDelegate
      ],
      initialRoute: initialRoute,
      onGenerateRoute: RouteGenerator.generateRoute,
      theme: ThemeData(
        primaryColor: Helpers.hexToColor('#456990'),
        primarySwatch:
            Helpers.createMaterialColor(Helpers.hexToColor('#153952')),
        fontFamily: 'MontserratMedium',
      ),
      // TODO: find another package
      home: LandingPage(),
      builder: (BuildContext context, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                // Provider.of<Ads>(context).showingAds &&
                //         Provider.of<Ads>(context).isBannerReady
                //     ? Provider.of<Ads>(context).showBanner()
                //     : Container(),
                // Expanded(child: child!),
                ShowCaseWidget(
                  onStart: (index, key) {
                    debugPrint('onStart: $index, $key');
                  },
                  onComplete: (index, key) {
                    debugPrint('onComplete: $index, $key');
                    if (index == 4) {}
                  },
                  blurValue: 1,
                  autoPlayDelay: const Duration(seconds: 3),
                  builder: (context) => Expanded(child: child!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

detectFirstTime() async {
  var lucraPrefs = prefs.get('profits');
  if (lucraPrefs == null) {
    initialRoute = '/slides';
    var encodedMap = json.encode({'balanceGroups': []});
    await prefs.setString('profits', encodedMap.toString());
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lucra/helpers/helpers.dart';
import 'package:lucra/locales.dart';
import 'package:lucra/providers/ads.dart';
import 'package:lucra/providers/balance_groups.dart';
import 'package:lucra/route_generator.dart';
import 'package:lucra/screens/landing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  runApp(
    LocalizedApp(
      delegate,
      const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final localizationDelegate = LocalizedApp.of(context).delegate;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BalanceGroups>(create: (_) => BalanceGroups()),
        ChangeNotifierProvider<Ads>(create: (_) => Ads()),
      ],
      child: MaterialApp(
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
        // ShowCaseWidget(
        //   onStart: (index, key) {
        //     // print('onStart: $index, $key');
        //   },
        //   onComplete: (index, key) {
        //     // log('onComplete: $index, $key');
        //     // if (index == 4) {
        //     //   SystemChrome.setSystemUIOverlayStyle(
        //     //     SystemUiOverlayStyle.light.copyWith(
        //     //       statusBarIconBrightness: Brightness.dark,
        //     //       statusBarColor: Colors.white,
        //     //     ),
        //     //   );
        //     // }
        //   },
        //   blurValue: 1,
        //   autoPlayDelay: const Duration(seconds: 3),
        //   builder: Builder(
        //     builder: (context) => LandingPage(),
        //   ),
        // ),
        builder: (BuildContext context, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Column(
              children: [
                Provider.of<Ads>(context).showAds &&
                        Provider.of<Ads>(context).isBannerReady
                    ? Provider.of<Ads>(context).showBanner()
                    : Container(),
                Expanded(child: child!),
              ],
            ),
          );
        },
      ),
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

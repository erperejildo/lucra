import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:lucra/main.dart';
import 'package:lucra/models/balance.dart';
import 'package:lucra/models/real_money.dart';
import 'package:lucra/providers/balance_groups.dart';
import 'package:provider/provider.dart';

class Helpers {
  static TextStyle headerTitleStyle = TextStyle(
      color: Colors.grey[800], fontWeight: FontWeight.w400, fontSize: 16.0);
  static TextStyle headerSubtitleStyle =
      TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w300);
  static final TextStyle noDataStyle = TextStyle(
      color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 14);

  static hexToColor(String hexString, {String alphaChannel = 'FF'}) {
    return Color(
      int.parse(
        hexString.replaceFirst('#', '0x$alphaChannel'),
      ),
    );
  }

  static getSavedLanguage(BuildContext context) {
    var options = prefs.get('options');
    // first time we initiate the app there are no default options yet so we create them
    if (options == null) {
      options = json.encode({
        'language': Platform.localeName.split('_')[0], // default phone language
      });
      prefs.setString('options', options.toString());
    }

    final Map optionsMap = json.decode(options.toString());
    return Locale(optionsMap['language'], '');
  }

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  static getMoney(dynamic money) {
    if (money == null) {
      money = 0;
    } else {
      if (money is String) {
        money = double.parse(money);
        // money = 5.5;
      }
    }

    final Map prefsDecoded = json.decode(prefs.get("options").toString());

    String lang = prefsDecoded["language"];
    // TODO: figure out how to show Brazilian currency
    if (lang == 'pt') {
      lang = 'es';
    }

    var savedCurrency = prefsDecoded['currency'];

    final formattedMoney = NumberFormat.simpleCurrency(
      name: savedCurrency,
      locale: lang,
      decimalDigits: money % 1 == 0 ? 0 : prefsDecoded["decimals"],
    ).format(money);

    return formattedMoney.toString();
  }

  static String showFrequency(int timesAYear) {
    switch (timesAYear) {
      case 12:
        return 'monthly';
      case 1:
        return 'annually';
      default:
        return 'daily';
    }
  }

  static contactUs(BuildContext context) async {
    String phoneInfo;
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;
      var manufacturer = androidInfo.manufacturer;
      var model = androidInfo.model;
      phoneInfo = 'Android $release (SDK $sdkInt), $manufacturer $model';
    } else {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      var name = iosInfo.name;
      var model = iosInfo.model;
      phoneInfo = '$systemName $version, $name $model';
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final Email newEmail = Email(
      body: '',
      subject: "Lucra (" + packageInfo.version + ") - " + phoneInfo,
      recipients: ["drodriguez.apps@gmail.com"],
      isHTML: false,
    );
    await FlutterEmailSender.send(newEmail);
  }

  static RealMoney calculateBalance(BuildContext context, Balance balance,
      [bool global = false]) {
    if (!global) {
      return calculateRealMoney(balance);
    }

    RealMoney realMoneyTotal = RealMoney(
      second: 0,
      minute: 0,
      hour: 0,
      day: 0,
      month: 0,
      year: 0,
      untilNow: 0,
    );

    for (var balance
        in Provider.of<BalanceGroups>(context, listen: false).list) {
      RealMoney realMoney = calculateRealMoney(balance);
      realMoneyTotal.second = realMoneyTotal.second + realMoney.second;
      realMoneyTotal.minute = realMoneyTotal.minute + realMoney.minute;
      realMoneyTotal.hour = realMoneyTotal.hour + realMoney.hour;
      realMoneyTotal.day = realMoneyTotal.day + realMoney.day;
      realMoneyTotal.month = realMoneyTotal.month + realMoney.month;
      realMoneyTotal.year = realMoneyTotal.year + realMoney.year;
      realMoneyTotal.untilNow = realMoneyTotal.untilNow + realMoney.untilNow;
    }

    return realMoneyTotal;
  }

  static RealMoney calculateRealMoney(Balance balance) {
    RealMoney realMoney = RealMoney(
      second: 0,
      minute: 0,
      hour: 0,
      day: 0,
      month: 0,
      year: 0,
      untilNow: 0,
    );
    // String paymentPeriodText = '';
    // 30.4167 days in a month
    // double secondsInAMonth = 30.4167 * 24 * 60 * 60;
    double secondsInADay = 24 * 60 * 60;
    double secondsInAYear = 365 * secondsInADay;

    Duration timeDiff =
        DateTime.now().difference(DateTime.parse(balance.fromDate));

    switch (balance.timesAYear) {
      case 12:
        // paymentPeriodText = ' a month';
        realMoney.second = balance.balance / (30.4167 * 24 * 60 * 60);
        break;
      case 1:
        // paymentPeriodText = ' a year';
        realMoney.second = balance.balance / secondsInAYear;
        break;
      default: // daily
        // paymentPeriodText = ' a day';
        realMoney.second = balance.balance / secondsInADay;
        break;
    }

    realMoney.minute = realMoney.second * 60;
    realMoney.hour = realMoney.minute * 60;
    realMoney.day = realMoney.hour * 24;
    realMoney.month = realMoney.day * 30.4167;
    realMoney.year = (realMoney.month * 12);

    realMoney.untilNow = timeDiff.inSeconds * realMoney.second;

    return realMoney;
  }
}

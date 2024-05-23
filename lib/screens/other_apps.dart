import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherAppsScreen extends StatefulWidget {
  @override
  _OtherAppsScreenState createState() => _OtherAppsScreenState();
}

class _OtherAppsScreenState extends State<OtherAppsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          translate('other_apps.title'),
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Text(
                translate("other_apps.app0.title"),
                style: const TextStyle(fontSize: 18),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Image.asset(
                    "assets/images/other-apps/0.png",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  translate("other_apps.app0.desc"),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (Platform.isAndroid) {
                    launchUrl(
                        'https://play.google.com/store/apps/details?id=com.drodriguez.profits'
                            as Uri);
                  } else {
                    launchUrl(
                        'https://apps.apple.com/us/app/balance-in-real-time/id1606458998'
                            as Uri);
                  }
                },
                child: Text(
                  translate("other_apps.install"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

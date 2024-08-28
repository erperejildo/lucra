import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/error_image.dart';

class OtherAppsScreen extends StatefulWidget {
  const OtherAppsScreen({Key? key}) : super(key: key);

  @override
  OtherAppsScreenState createState() => OtherAppsScreenState();
}

class OtherAppsScreenState extends State<OtherAppsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(translate('other_apps.title')),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                ...app(0),
                ...app(1),
                ...app(2),
                ...app(3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> app(int index) {
    return [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 16.0),
            constraints: const BoxConstraints(maxWidth: 150),
            child: CachedNetworkImage(
              imageUrl: translate('other_apps.app$index.img'),
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor),
              ),
              errorWidget: (context, url, error) => errorImage(context),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  translate('other_apps.app$index.title'),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    if (Platform.isAndroid) {
                      launchUrl(Uri.parse(
                          translate("other_apps.app$index.android_link")));
                    } else {
                      launchUrl(Uri.parse(
                          translate("other_apps.app$index.ios_link")));
                    }
                  },
                  child: PlatformText(
                    translate("other_apps.install"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 32),
        child: Text(
          translate("other_apps.app$index.desc"),
        ),
      ),
    ];
  }
}

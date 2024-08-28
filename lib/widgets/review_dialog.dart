import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../helpers/helpers.dart';
import '../main.dart';

class ReviewDialog {
  check(BuildContext context) async {
    var timesOpen = prefs.getInt('timesOpen');
    if (timesOpen is! int) return prefs.setInt('timesOpen', 1);
    if (timesOpen < 0) return;
    timesOpen++;
    prefs.setInt('timesOpen', timesOpen);
    if (timesOpen < 3) return;

    show(context);
  }

  show(BuildContext context) {
    return WidgetsBinding.instance.addPostFrameCallback((_) async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(translate('write_review')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(translate('write_review_desc')),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(translate('ok')),
                onPressed: () async {
                  prefs.setInt('timesOpen', -1);
                  Helpers.openGooglePlay();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(translate('maybe_later')),
                onPressed: () {
                  prefs.setInt('timesOpen', 0);
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  translate('dont_ask_again'),
                  textAlign: TextAlign.right,
                ),
                onPressed: () {
                  prefs.setInt('timesOpen', -1);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }
}

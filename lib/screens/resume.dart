import 'dart:async';
import 'dart:io';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lucra/helpers/helpers.dart';
import 'package:lucra/models/balance.dart';
import 'package:lucra/models/real_money.dart';
import 'package:lucra/providers/balance_groups.dart';
import 'package:lucra/widgets/real_balance.dart';
import 'package:provider/provider.dart';

class ResumeScreen extends StatefulWidget {
  ResumeScreen({Key? key, required this.balance, this.global = false})
      : super(key: key);
  Balance balance;
  bool global;

  @override
  _ResumeScreenState createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  Timer? timer;
  RealMoney realMoney = RealMoney(
    second: 0,
    minute: 0,
    hour: 0,
    day: 0,
    month: 0,
    year: 0,
    untilNow: 0,
  );

  @override
  void initState() {
    super.initState();
    // resumeColor =
    //     widget.balance.balance >= 0 ? Colors.green[800] : Colors.red[800];

    realMoney =
        Helpers.calculateBalance(context, widget.balance, widget.global);
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        realMoney =
            Helpers.calculateBalance(context, widget.balance, widget.global);
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
            widget.global ? translate('total_balance') : widget.balance.title),
        actions: <Widget>[
          Visibility(
            visible: !widget.global,
            child: optionsAction(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: RealBalance(
          realMoney: realMoney,
          balance: widget.balance,
        ),
      ),
    );
  }

  Widget optionsAction() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
        onPressed: () {
          showAdaptiveActionSheet(
            context: context,
            actions: <BottomSheetAction>[
              BottomSheetAction(
                title: Text(translate('edit')),
                onPressed: (context) {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushNamed('/new-balance', arguments: widget.balance)
                      .then((balance) {
                    if (balance is Balance) {
                      widget.balance = balance;
                      realMoney =
                          Helpers.calculateBalance(context, widget.balance);
                      setState(() {});
                    }
                  });
                },
              ),
              BottomSheetAction(
                title: Text(
                  translate('delete'),
                  style: const TextStyle(color: Colors.red),
                ),
                onPressed: (context) async {
                  Navigator.of(context).pop();
                  await deleteConfirmation(context);
                },
              ),
            ],
            cancelAction: CancelAction(
              title: Text(translate('cancel')),
            ),
            // onPressed parameter is optional by default will dismiss the ActionSheet
          );
        },
        icon: Icon(
          Platform.isAndroid
              ? LineIcons.verticalEllipsis
              : LineIcons.horizontalEllipsis,
        ),
      ),
    );
  }

  Future deleteConfirmation(BuildContext context) {
    return showPlatformDialog(
      context: context,
      builder: (context) {
        return PlatformAlertDialog(
          title: Text(translate('delete_title')),
          content: Text(translate('delete_desc')),
          actions: <Widget>[
            TextButton(
              child: PlatformText(
                translate('delete'),
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                // Provider.of<AdState>(context, listen: false)
                //     .showInterstitialAd();
                await Provider.of<BalanceGroups>(context, listen: false)
                    .deleteBalance(widget.balance.id);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: PlatformText(translate('cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

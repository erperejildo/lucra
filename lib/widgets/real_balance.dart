import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:lucra/helpers/helpers.dart';
import 'package:lucra/main.dart';
import 'package:lucra/models/balance.dart';
import 'package:lucra/models/real_money.dart';
import 'package:lucra/providers/balance_groups.dart';
import 'package:provider/provider.dart';

class RealBalance extends StatefulWidget {
  const RealBalance(
      {super.key, required this.realMoney, required this.balance});
  final RealMoney realMoney;
  final Balance balance;

  // final RealMoney realMoney;
  // final Balance balance;
  // RealBalance({required this.realMoney, required this.balance});

  @override
  _RealBalanceState createState() => _RealBalanceState();
}

class _RealBalanceState extends State<RealBalance> {
  String paymentPeriodText = '';
  final Map _options = json.decode(prefs.get("options").toString());
  String language = '';

  @override
  void initState() {
    super.initState();
    language = _options['language'];
  }

  @override
  Widget build(BuildContext context) {
    final resumeColor =
        widget.realMoney.untilNow >= 0 ? Colors.green[800] : Colors.red[800];
    final TextStyle textStyle = TextStyle(fontSize: 18, color: resumeColor);

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              translate(widget.realMoney.untilNow >= 0 ? 'earned' : 'paid')
                  .toUpperCase(),
              style: TextStyle(fontSize: 24, color: resumeColor),
            ),
            SizedBox(
              width: double.infinity > 400 ? 400 : double.infinity,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                    (Helpers.getMoney(widget.realMoney.untilNow *
                        (widget.realMoney.untilNow < 0 ? -1 : 1))),
                    style: TextStyle(color: resumeColor)),
              ),
            ),
            Text(
              '${translate('since')} ${DateFormat.yMMMd(language).format(widget.balance.id != '' ? DateTime.parse(
                  widget.balance.fromDate,
                ) : Provider.of<BalanceGroups>(context).firstDate!)}',
              style: textStyle,
            ),
            Visibility(
              visible: widget.balance.id != '',
              child: Text(
                Helpers.getMoney(widget.balance.balance *
                        (widget.realMoney.untilNow < 0 ? -1 : 1)) +
                    paymentPeriodText +
                    ' ' +
                    translate(Helpers.showFrequency(widget.balance.timesAYear))
                        .toLowerCase(),
                style: textStyle,
              ),
            ),
            Container(height: 25),
            Visibility(
              visible: widget.balance.image.isNotEmpty,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.realMoney.untilNow >= 0
                        ? Colors.green[800]!
                        : Colors.red[800]!,
                    width: 8,
                  ),
                ),
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage:
                      CachedNetworkImageProvider(widget.balance.image),
                  onBackgroundImageError: (exception, stackTrace) {
                    const Icon(Icons.error);
                  },
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            Container(height: 25),
            Table(
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Text(
                        Helpers.getMoney(widget.realMoney.second),
                        textAlign: TextAlign.right,
                        style: textStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        translate('per_second'),
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Text(
                        Helpers.getMoney(
                            widget.realMoney.minute), // pero minute
                        textAlign: TextAlign.right,
                        style: textStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        translate('per_minute'),
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Text(
                        Helpers.getMoney(widget.realMoney.hour), // per hour
                        textAlign: TextAlign.right,
                        style: textStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        translate('per_hour'),
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Text(
                        Helpers.getMoney(widget.realMoney.day), // per day
                        textAlign: TextAlign.right,
                        style: textStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        translate('per_day'),
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Text(
                        Helpers.getMoney(widget.realMoney.month), // per month
                        textAlign: TextAlign.right,
                        style: textStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        translate('per_month'),
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Text(
                        Helpers.getMoney(widget.realMoney.year), // per year
                        textAlign: TextAlign.right,
                        style: textStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        translate('per_year'),
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

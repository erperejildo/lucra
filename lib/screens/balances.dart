import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lucra/helpers/helpers.dart';
import 'package:lucra/providers/balance_groups.dart';
import 'package:provider/provider.dart';

class BalancesScreen extends StatefulWidget {
  const BalancesScreen({Key? key, required this.incomeCardKey})
      : super(key: key);
  final GlobalKey incomeCardKey;

  @override
  _BalancesScreenState createState() => _BalancesScreenState();
}

class _BalancesScreenState extends State<BalancesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // no back button
          title: Text(translate('balances')),
          actions: <Widget>[
            addButton(),
            // TextButton(
            //   onPressed: () {
            //     Provider.of<AdState>(context, listen: false).checkInit();
            //   },
            //   child: Text(
            //     "Show ads",
            //     style: TextStyle(color: Colors.red),
            //   ),
            // ),
          ],
        ),
        body: listContainer(),
      ),
    );
  }

  Widget addButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/new-balance', arguments: null);
        },
        icon: const Icon(LineIcons.plus),
      ),
    );
  }

  Widget listContainer() {
    if (Provider.of<BalanceGroups>(context).list.isEmpty) {
      return noList(context);
    }
    return list(context);
  }

  Widget noList(BuildContext context) {
    return Center(
      child: Text(
        translate('no_balances'),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget list(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return GridView.count(
      childAspectRatio: 1,
      padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
      crossAxisCount: deviceWidth > 700 ? (deviceWidth * 0.006).round() : 3,
      children: List.generate(
        Provider.of<BalanceGroups>(context, listen: false).list.length,
        (index) {
          // TODO: find a different package
          // if (index == 0) {
          //   return Showcase(
          //     key: widget.incomeCardKey,
          //     // enableAutoPlayLock: true,
          //     disableBarrierInteraction: true,
          //     description:
          //         'This is your balances page. In here, you will find different expenses and incomes.',
          //     onTargetClick: () => debugPrint('target clicked'),
          //     disposeOnTap: true,
          //     child: balanceCard(
          //         context,
          //         Provider.of<BalanceGroups>(context, listen: false)
          //             .list[index]),
          //   );
          // }
          return balanceCard(context,
              Provider.of<BalanceGroups>(context, listen: false).list[index]);
        },
      ),
    );
  }

  Widget balanceCard(BuildContext context, balance) {
    return GestureDetector(
      onPanDown: (_) =>
          Navigator.of(context).pushNamed('/resume', arguments: balance),
      child: Card(
        // key: balance.balance > 0 ? widget.incomeCardKey : null,
        color: balance.balance > 0 ? Colors.green[800] : Colors.red[800],
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AutoSizeText(
                balance.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
                maxLines: 2,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      balance.balance.toString(),
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Text(
                    translate(Helpers.showFrequency(balance.timesAYear))
                        .toLowerCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Container(height: 5),
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      translate('since') +
                          ' ' +
                          DateFormat.yMMMd()
                              .format(DateTime.parse(balance.fromDate)),
                      textAlign: TextAlign.justify,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

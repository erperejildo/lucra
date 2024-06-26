import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lucra/helpers/helpers.dart';
import 'package:lucra/models/balance.dart';
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
    return Scaffold(
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

  Widget balanceCard(BuildContext context, Balance balance) {
    return GestureDetector(
      onPanDown: (_) =>
          Navigator.of(context).pushNamed('/resume', arguments: balance),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: (balance.image.isNotEmpty
            ? Colors.transparent
            : balance.balance > 0
                ? Colors.green[800]
                : Colors.red[800])!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 2,
        margin: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Visibility(
              visible: balance.image.isNotEmpty,
              child: Image.network(
                balance.image,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48.0,
                    ),
                  );
                },
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(balance.image.isNotEmpty ? 0 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: balance.image.isEmpty
                    ? MainAxisAlignment.spaceAround
                    : MainAxisAlignment.end,
                children: [
                  Visibility(
                    visible: balance.image.isEmpty,
                    child: AutoSizeText(
                      balance.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor(balance),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        color: balance.image.isNotEmpty
                            ? Colors.black.withOpacity(0.7)
                            : Colors.transparent,
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            balance.balance.toString(),
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              color: textColor(balance),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: balance.image.isEmpty,
                        child: Text(
                          translate(Helpers.showFrequency(balance.timesAYear))
                              .toLowerCase(),
                          style: TextStyle(
                              color: textColor(balance),
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Visibility(
                        visible: balance.image.isEmpty,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            '${translate('since')} ${DateFormat.yMMMd().format(DateTime.parse(balance.fromDate))}',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                color: textColor(balance), fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color textColor(Balance balance) {
    return balance.image.isEmpty
        ? Colors.white
        : (balance.balance > 0 ? Colors.green : Colors.red);
  }
}

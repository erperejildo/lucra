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
  const BalancesScreen({
    Key? key,
    required this.navigationBalancesKey,
    required this.incomeCardKey,
    required this.expenseCardKey,
    required this.addButtonKey,
  }) : super(key: key);
  final GlobalKey navigationBalancesKey;
  final GlobalKey incomeCardKey;
  final GlobalKey expenseCardKey;
  final GlobalKey addButtonKey;

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
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // no back button
        title: Text(key: widget.navigationBalancesKey, translate('balances')),
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
        key: widget.addButtonKey,
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
          return balanceCard(
              context,
              Provider.of<BalanceGroups>(context, listen: false).list[index],
              index);
        },
      ),
    );
  }

  Widget balanceCard(BuildContext context, Balance balance, int index) {
    return GestureDetector(
      key: index == 0
          ? widget.incomeCardKey
          : index == 1
              ? widget.expenseCardKey
              : null,
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
                  title(balance),
                  Column(
                    children: [
                      price(balance),
                      frequency(balance),
                      since(balance),
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

  Widget title(Balance balance) {
    return Visibility(
      visible: balance.image.isEmpty,
      child: Align(
        alignment: Alignment.centerLeft,
        child: AutoSizeText(
          balance.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor(balance),
            fontSize: 12,
          ),
          maxLines: 2,
        ),
      ),
    );
  }

  Widget price(Balance balance) {
    return Container(
      color: balance.image.isNotEmpty
          ? Colors.black.withOpacity(0.7)
          : Colors.transparent,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
    );
  }

  Widget frequency(Balance balance) {
    return Visibility(
      visible: balance.image.isEmpty,
      child: Text(
        translate(Helpers.showFrequency(balance.timesAYear)).toLowerCase(),
        style: TextStyle(
            color: textColor(balance),
            fontSize: 12,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget since(Balance balance) {
    return Visibility(
      visible: balance.image.isEmpty,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          '${translate('since')} ${DateFormat.yMMMd().format(DateTime.parse(balance.fromDate))}',
          textAlign: TextAlign.justify,
          style: TextStyle(color: textColor(balance), fontSize: 12),
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

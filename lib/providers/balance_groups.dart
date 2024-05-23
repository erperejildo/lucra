import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lucra/main.dart';
import 'package:lucra/models/balance.dart';

class BalanceGroups extends ChangeNotifier {
  List<Balance> list = [];
  DateTime? firstDate;

  updateUI() {
    notifyListeners();
  }

  getBalanceGroups() async {
    final lucraPrefs = await json.decode(prefs.get('profits').toString());

    if (lucraPrefs == null) {
      return;
    }

    list = [];
    for (var balance in lucraPrefs['balanceGroups']) {
      list.add(
        Balance(
          id: balance['id'],
          title: balance['title'],
          balance: balance['balance'],
          fromDate: balance['fromDate'],
          timesAYear: balance['timesAYear'],
        ),
      );
    }
    getFirstDate();
    updateUI();
  }

  saveBalances() async {
    var lucraPrefs = prefs.get('profits');
    var lucraPrefsMap = await json.decode(lucraPrefs.toString());
    List<Map> balanceGroupsMap = [];

    for (var balance in list) {
      balanceGroupsMap.add(balance.toMap());
    }

    lucraPrefsMap['balanceGroups'] = balanceGroupsMap;
    await prefs.setString('profits', json.encode(lucraPrefsMap).toString());
    await getBalanceGroups();
    getFirstDate();
  }

  addBalance(Balance balance) async {
    list.add(balance);
    updateUI();
    await saveBalances();
  }

  addBalances(List<Balance> balances) async {
    list.addAll(balances);
    await saveBalances();
  }

  deleteBalances() async {
    list = [];
  }

  updateBalance(Balance balance) async {
    for (var i = 0; i < list.length; i++) {
      if (list[i].id == balance.id) {
        list[i] = balance;
        break;
      }
    }
    await saveBalances();
  }

  deleteBalance(String balanceId) async {
    List<Balance> updatedList =
        list.where((balance) => balance.id != balanceId).toList();
    list = [];
    await addBalances(updatedList);
  }

  getFirstDate() {
    firstDate = DateTime.now();
    for (var balance in list) {
      final parsedFromDate = DateTime.parse(balance.fromDate);
      final difference = firstDate!.difference(parsedFromDate).inSeconds;
      if (difference > 0) {
        firstDate = parsedFromDate;
      }
    }
  }
}

final BalanceGroups balanceGroups = BalanceGroups();

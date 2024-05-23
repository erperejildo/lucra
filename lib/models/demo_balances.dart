import 'package:flutter_translate/flutter_translate.dart';
import 'package:lucra/models/balance.dart';
import 'package:uuid/uuid.dart';

DateTime formatedDate = DateTime(
  2021,
  11, // month
  15, // day
  12, // hour
  0, // minute
);

final List<Balance> demoBalanceGroups = [
  Balance(
    id: const Uuid().v4(),
    title: translate('salary_example'),
    balance: 40000,
    // fromDate: DateFormat.yMMMd().format(DateTime.now()),
    fromDate: formatedDate.toString(),
    timesAYear: 1,
  ),
  Balance(
    id: const Uuid().v4(),
    title: translate('mortgage_example'),
    balance: -250,
    fromDate: DateTime(
      2021,
      12, // month
      9, // day
      12, // hour
      0, // minute
    ).toString(),
    timesAYear: 12,
  ),
];

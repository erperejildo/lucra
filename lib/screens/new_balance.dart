import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lucra/helpers/helpers.dart';
import 'package:lucra/helpers/validators.dart';
import 'package:lucra/models/balance.dart';
import 'package:lucra/models/real_money.dart';
import 'package:lucra/providers/ads.dart';
import 'package:lucra/providers/balance_groups.dart';
import 'package:lucra/widgets/real_balance.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NewBalanceScreen extends StatefulWidget {
  NewBalanceScreen({Key? key, this.balance}) : super(key: key);
  Balance? balance;

  @override
  _NewBalanceScreenState createState() => _NewBalanceScreenState();
}

class _NewBalanceScreenState extends State<NewBalanceScreen> {
  bool newBalance = true;
  Timer? timer;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  List<Map> periodsDropdown = [
    // {
    //   "name": "one_off",
    //   "value": 0,
    // },
    {
      "name": "daily",
      "value": 365,
    },
    {
      "name": "monthly",
      "value": 12,
    },
    {
      "name": "annually",
      "value": 1,
    },
  ];
  int _period = 12;
  DateTime? fromDate;
  RealMoney realMoney = RealMoney(
    second: 0,
    minute: 0,
    hour: 0,
    day: 0,
    month: 0,
    year: 0,
    untilNow: 0,
  );
  bool noInitialDate = false;
  String balanceId = const Uuid().v4();

  @override
  void initState() {
    super.initState();
    if (widget.balance != null) {
      newBalance = false;
      balanceId = widget.balance!.id;
      _period = widget.balance!.timesAYear;
      fromDate = DateTime.parse(widget.balance!.fromDate);
      _dateController.text = DateFormat.yMMMd()
          .format(DateTime.parse(widget.balance!.fromDate.toString()));
      _numberController.text = widget.balance!.balance.toString();
      _titleController.text = widget.balance!.title;
      _imageController.text = widget.balance!.image;
      calculate();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(newBalance
            ? translate('new_profit_expense')
            : widget.balance!.title),
        actions: <Widget>[
          saveButton(),
        ],
      ),
      body: SingleChildScrollView(child: form()),
    );
  }

  Widget saveButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            Provider.of<Ads>(context, listen: false).showInterstitialAd();
            if (newBalance) {
              await Provider.of<BalanceGroups>(context, listen: false)
                  .addBalance(widget.balance!);
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/');
              Navigator.of(context)
                  .pushNamed('/resume', arguments: widget.balance);
            } else {
              await Provider.of<BalanceGroups>(context, listen: false)
                  .updateBalance(widget.balance!);
              Navigator.of(context).pop(widget.balance);
            }
          }
        },
        icon: const Icon(LineIcons.save),
      ),
    );
  }

  Widget form() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          period(),
          initialDate(),
          profit(),
          title(),
          image(),
          total(),
        ],
      ),
    );
  }

  Widget period() {
    return ListTile(
      leading: const Icon(LineIcons.syncIcon),
      title: Text(translate('payment')),
      trailing: DropdownButton<int>(
        value: _period,
        items: periodsDropdown.map<DropdownMenuItem<int>>((Map value) {
          return DropdownMenuItem<int>(
            value: value["value"],
            child: Text(translate(value["name"])),
          );
        }).toList(),
        onChanged: (newPeriod) async {
          setState(() {
            _period = newPeriod!;
          });
          calculate();
        },
      ),
    );
  }

  Widget profit() {
    return ListTile(
      leading: const Icon(LineIcons.coins),
      title: TextFormField(
        controller: _numberController,
        decoration: InputDecoration(
          labelText: translate('amount_per_period'),
          hintText: '100',
        ),
        keyboardType:
            const TextInputType.numberWithOptions(signed: true, decimal: true),
        // inputFormatters: <TextInputFormatter>[
        //   FilteringTextInputFormatter.allow(new RegExp("^-?\d")),
        // ],
        validator: (value) {
          return Validators.checkDouble(value!);
        },
        onChanged: (text) {
          calculate();
        },
      ),
      subtitle: Text(translate('expense_desc')),
    );
  }

  Widget title() {
    return ListTile(
      leading: const Icon(LineIcons.edit),
      title: TextFormField(
        controller: _titleController,
        decoration: InputDecoration(
          labelText: translate('name'),
          hintText: translate('salary'),
        ),
        maxLength: 20,
        keyboardType: TextInputType.text,
        validator: (value) {
          return Validators.checkInput(value!);
        },
      ),
    );
  }

  Widget image() {
    return ListTile(
      leading: const Icon(LineIcons.image),
      title: TextFormField(
        controller: _imageController,
        decoration: InputDecoration(
          labelText: translate('image'),
          hintText: translate('paste_url'),
        ),
        keyboardType: TextInputType.text,
        validator: (value) {
          return Validators.checkUrl(value!);
        },
      ),
      trailing: IconButton(
        icon: const Icon(LineIcons.paste),
        onPressed: () async {
          var url = await Clipboard.getData(Clipboard.kTextPlain);
          _imageController.text = url!.text ?? '';
        },
      ),
    );
  }

  bool isBalanceReady() {
    if (fromDate == null ||
        _numberController.text.isEmpty ||
        double.tryParse(_numberController.text) == null) {
      return false;
    }
    return true;
  }

  calculate() {
    if (!isBalanceReady()) {
      return;
    }
    timer?.cancel();

    widget.balance = Balance(
      id: balanceId,
      title: _titleController.text,
      balance: double.parse(_numberController.text),
      fromDate: fromDate.toString(),
      timesAYear: _period,
      image: _imageController.text,
    );

    setState(() {
      realMoney = Helpers.calculateBalance(context, widget.balance!);
    });
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (fromDate == null ||
          _numberController.text.isEmpty ||
          double.tryParse(_numberController.text) == null) {
        setState(() {});
        timer?.cancel();
        return;
      }

      widget.balance = Balance(
        id: balanceId,
        title: _titleController.text,
        balance: double.parse(_numberController.text),
        fromDate: fromDate.toString(),
        timesAYear: _period,
        image: _imageController.text,
      );
      if (mounted) {
        setState(() {
          realMoney = Helpers.calculateBalance(context, widget.balance!);
        });
      }
    });
  }

  Widget total() {
    if (!isBalanceReady()) {
      return Container();
    }

    return RealBalance(
      realMoney: realMoney,
      balance: widget.balance!,
    );
  }

  Widget initialDate() {
    return ListTile(
      leading: const Icon(LineIcons.calendarWithDayFocus),
      title: TextFormField(
        readOnly: true,
        controller: _dateController,
        decoration: InputDecoration(
          labelText: translate('initial_date'),
        ),
        onTap: () async {
          final _fromDate = await showDatePicker(
            context: context,
            initialDate: fromDate == null ? DateTime.now() : fromDate!,
            firstDate: DateTime(1900, 8),
            lastDate: DateTime.now(),
          );

          if (_fromDate != null) {
            _dateController.text =
                DateFormat.yMMMd().format(DateTime.parse(_fromDate.toString()));
            fromDate = _fromDate;
            noInitialDate = true;
            calculate();
            setState(() {});
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return translate('fill_field');
          }
          return null;
        },
      ),
      // onPanDown: () {
      //   dateTimePicker();
      // },
    );
  }
}

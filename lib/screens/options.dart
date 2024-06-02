import 'dart:convert';
import 'dart:io';

import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lucra/services/shop.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:lucra/helpers/helpers.dart';
import 'package:lucra/locales.dart';
import 'package:lucra/main.dart';
import 'package:lucra/services/loading.dart';

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  var _options;
  final List<int> _listOfDecimals = [0, 1, 2, 3, 4, 5];
  int? _decimals;
  String? _language;
  String _currencySymbol = "";

  @override
  void initState() {
    super.initState();
    getSavedParams();
  }

  getSavedParams() async {
    _options = json.decode(prefs.get('options').toString());
    _language = _options['language'];
    if (_options['decimals'] == null) {
      _decimals = 3;
    } else {
      _decimals = _options['decimals'];
    }

    var format = NumberFormat.simpleCurrency(locale: _language);
    if (_options['currency'] == null) {
      _currencySymbol = format.currencySymbol;
      _options['currency'] = format.currencyName;
      await prefs.setString('options', json.encode(_options));
    }
    setState(() {
      _currencySymbol = format.simpleCurrencySymbol(_options['currency']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(translate('options')),
      ),
      body: ListView(
        children: [
          decimals(),
          language(),
          currency(),
          buyVersion(),
          contactUs(),
          otherApps(),
          aboutUs(),
        ],
      ),
    );
  }

  Widget decimals() {
    return ListTile(
      leading: const Icon(LineIcons.calculator),
      title: Text(translate('decimals')),
      trailing: DropdownButton<int>(
        value: _decimals,
        items: _listOfDecimals.map<DropdownMenuItem<int>>((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(value.toString()),
          );
        }).toList(),
        onChanged: (newDecimals) async {
          setState(() {
            _decimals = newDecimals;
          });
          _options['decimals'] = newDecimals;
          await prefs.setString('options', json.encode(_options));
        },
      ),
    );
  }

  Widget language() {
    return ListTile(
      leading: const Icon(LineIcons.language),
      title: Text(translate('language')),
      trailing: DropdownButton<String>(
        value: _language,
        items: languagesDropdown.map<DropdownMenuItem<String>>((Map value) {
          return DropdownMenuItem<String>(
            value: value["value"],
            child: Text(value["name"]),
          );
        }).toList(),
        onChanged: (newLang) async {
          if (newLang is! String) return;

          final loading = Loading();
          await loading.load(
            context,
            translate('updating_language'),
          );
          // ignore: use_build_context_synchronously
          await changeLocale(context, newLang);
          _language = newLang;
          _options["language"] = newLang;
          await prefs.setString('options', json.encode(_options)).then((value) {
            Locale(newLang, '');
            loading.cancel(context);
          });
        },
      ),
    );
  }

  Widget currency() {
    return ListTile(
      leading: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Text(
          _currencySymbol,
          style: const TextStyle(fontSize: 30, color: Colors.grey, height: 1.3),
        ),
      ),
      title: Text(translate('currency')),
      onTap: () {
        showCurrencyPicker(
          context: context,
          searchHint: translate('search'),
          showFlag: true,
          showCurrencyName: true,
          showCurrencyCode: true,
          onSelect: (Currency currency) async {
            setState(() {
              _currencySymbol = currency.symbol;
            });
            _options['currency'] = currency.code;
            await prefs.setString('options', json.encode(_options));
          },
          favorite: [_options['currency']],
        );
      },
    );
  }

  Widget buyVersion() {
    return ListTile(
      leading: const Icon(LineIcons.shoppingCart),
      title: Text(translate('buy')),
      subtitle: Text(translate('buy_desc')),
      onTap: () async {
        await shop.buyProduct(shop.products[0]);
      },
    );
  }

  Widget contactUs() {
    return ListTile(
      leading: const Icon(LineIcons.envelopeAlt),
      title: Text(translate('contact_us')),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () async {
        await Helpers.contactUs(context);
      },
    );
  }

  Widget otherApps() {
    return ListTile(
      leading:
          Icon(Platform.isAndroid ? LineIcons.googlePlay : LineIcons.appStore),
      title: Text(translate('other_apps.title')),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () async {
        Navigator.of(context).pushNamed(
          '/other-apps',
        );
      },
    );
  }

  Widget aboutUs() {
    return ListTile(
      leading: const Icon(LineIcons.users),
      title: Text(translate('about_us')),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () async {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        return showAboutDialog(
          context: context,
          applicationName: 'Lucra',
          applicationVersion: packageInfo.version,
          children: [
            const Image(
              image: AssetImage('assets/images/icon.png'),
              height: 150,
            ),
          ],
        );
      },
    );
  }
}
